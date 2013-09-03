require_relative '../test_helper'

class StatusDatabaseTest < ActiveSupport::TestCase
	include Synapse::Configuration::Dependent

	depends_on :gateway
	depends_on :event_bus
	depends_on :event_store

	def setup
		Synapse.container.inject_into self
		@db = EsGfs::InMemoryStatusDatabase.new
		self.event_bus.subscribe @db
	end

  def teardown
    event_store.clear
  end

	def test_location_creation
    location_id = send_command(EsGfs::CreateLocation, "main")

    location = @db.locations[location_id]
    assert_not_nil location
    assert_equal location_id, location.id
    assert_equal "main", location.name
	end

  def setup_simple_structure
    @main_location_id = send_command(EsGfs::CreateLocation, "main")
    @remote_location_id = send_command(EsGfs::CreateLocation, "remote")

    @home_directory_id = send_command(EsGfs::CreateDirectory, "home", @main_location_id)
    @public_directory_id = send_command(EsGfs::CreateDirectory, "public", @main_location_id, @home_directory_id)

    @a_file_id = send_command(EsGfs::CreateFile, @public_directory_id, "a.txt", "text/pain")
    @b_file_id = send_command(EsGfs::CreateFile, @public_directory_id, "b.txt", "text/pain")

    send_command EsGfs::LinkFileLocation, @a_file_id, @main_location_id, "/home/public/a.txt"
    send_command EsGfs::LinkFileLocation, @a_file_id, @remote_location_id, "/srv/production/home/public/a.txt"
    send_command EsGfs::LinkFileLocation, @b_file_id, @main_location_id, "/home/public/b.txt"
  end

  def test_simple_structure
    setup_simple_structure

    assert_not_nil @db.directories[@home_directory_id]
    assert_equal "home", @db.directories[@home_directory_id].name
    assert_equal "home", @db.directories[@home_directory_id].path
    assert_equal @db.file_map["home"], @db.directories[@home_directory_id]

    assert_not_nil @db.directories[@public_directory_id]
    assert_equal "public", @db.directories[@public_directory_id].name
    assert_equal "home/public", @db.directories[@public_directory_id].path
    assert_equal @db.file_map["home/public"], @db.directories[@public_directory_id]

    file = @db.files[@a_file_id]
    assert_not_nil file
    assert_equal "a.txt", file.name
    assert_equal "text/pain", file.mime_type
    assert_equal "home/public/a.txt", file.path
    assert_equal @db.file_map["home/public/a.txt"], file
    assert_equal "/home/public/a.txt", file.locations[@main_location_id]
    assert_equal "/srv/production/home/public/a.txt", file.locations[@remote_location_id]

    file = @db.files[@b_file_id]
    assert_not_nil file
    assert_equal "b.txt", file.name
    assert_equal "text/pain", file.mime_type
    assert_equal "home/public/b.txt", file.path
    assert_equal @db.file_map["home/public/b.txt"], file
    assert_equal "/home/public/b.txt", file.locations[@main_location_id]
    assert_nil file.locations[@remote_location_id]
  end

  def test_file_location_unlinked
    setup_simple_structure

    send_command EsGfs::UnlinkFileLocation, @a_file_id, @remote_location_id
    send_command EsGfs::UnlinkFileLocation, @b_file_id, @main_location_id

    file = @db.files[@a_file_id]
    assert_equal "/home/public/a.txt", file.locations[@main_location_id]
    assert_nil file.locations[@remote_location_id]

    file = @db.files[@b_file_id]
    assert file.locations.empty?
  end

end