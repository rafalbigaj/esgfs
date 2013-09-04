require_relative '../test_helper'

class DirectoryTest < ActiveSupport::TestCase
	include EsGfs::Testing

	def test_create
		command = EsGfs::CreateDirectory.new("root", nil)
		directory_id = gateway.send_and_wait command
    assert_not_nil directory_id

    events = event_store.read_events('Directory', directory_id).to_a.map(&:payload)

    assert_equal 1, events.size
    event = events[0]
    assert_kind_of EsGfs::DirectoryCreated, event
    assert_not_nil event.id
    assert_equal "root", event.name
    assert_nil event.owner
	end

	def test_create_subdirectory
    directory_id = send_command(EsGfs::CreateDirectory, "root", nil)
    a_directory_id = send_command(EsGfs::CreateDirectory, "a", nil, directory_id)
    b_directory_id = send_command(EsGfs::CreateDirectory, "b", nil, a_directory_id)

		events = event_store.read_events('Directory', b_directory_id).to_a.map(&:payload)
		assert_kind_of EsGfs::DirectoryCreated, events[0]

		event = events[0]
		assert_equal b_directory_id, event.id
		assert_equal "b", event.name
		assert_equal a_directory_id, event.parent_id

		events = event_store.read_events('Directory', a_directory_id).to_a.map(&:payload)
		assert_kind_of EsGfs::DirectoryCreated, events[0]
		assert_kind_of EsGfs::SubDirectoryAdded, events[1]

		event = events[1]
		assert_equal b_directory_id, event.id
		assert_equal "b", event.name
	end

	def test_add_file
    directory_id = send_command(EsGfs::CreateDirectory, "root", nil)
    file_id = send_command(EsGfs::CreateFile, directory_id, "test.txt", "text/plain")

		events = event_store.read_events('File', file_id).to_a.map(&:payload)
    assert_equal 1, events.size
    assert_kind_of EsGfs::FileCreated, events[0]

		file_event = events[0]
		assert_equal file_id, file_event.id
		assert_equal "test.txt", file_event.name
		assert_equal "text/plain", file_event.mime_type
		assert_equal directory_id, file_event.directory_id

		assert_equal 2, event_store.read_events('Directory', directory_id).to_a.size

		assert_raise Synapse::Command::CommandExecutionError do
			command = EsGfs::CreateFile.new(directory_id, "test.txt", "text/plain")
			gateway.send_and_wait command
		end

		assert_equal 2, event_store.read_events('Directory', directory_id).to_a.size, "No event should be added after exception"
	end

  def setup_simple_file_structure
    @location_id = send_command(EsGfs::CreateLocation, "main")
    @directory_id = send_command(EsGfs::CreateDirectory, "root", nil)
    @file_id = send_command(EsGfs::CreateFile, @directory_id, "test.txt", "text/plain")
    send_command EsGfs::LinkFileLocation, @file_id, @location_id, "/home/repository/main/test.txt"
  end

	def test_add_file_location
    setup_simple_file_structure

		events = event_store.read_events('File', @file_id).to_a.map(&:payload)
		assert_equal 2, events.size
		assert_kind_of EsGfs::FileCreated, events[0]
		assert_kind_of EsGfs::FileLocationLinked, events[1]

		event = events[1]
		assert_equal @location_id, event.location_id
		assert_equal "/home/repository/main/test.txt", event.path
	end

  def test_remove_file_location
    setup_simple_file_structure
    send_command EsGfs::UnlinkFileLocation, @file_id, @location_id

    events = event_store.read_events('File', @file_id).to_a.map(&:payload)
    assert_equal 3, events.size
    assert_kind_of EsGfs::FileCreated, events[0]
    assert_kind_of EsGfs::FileLocationLinked, events[1]
    assert_kind_of EsGfs::FileLocationUnlinked, events[2]

    event = events[2]
    assert_equal @location_id, event.location_id
  end

  def test_delete_file
    setup_simple_file_structure
    send_command EsGfs::DeleteFile, @file_id

    events = event_store.read_events('File', @file_id).to_a.map(&:payload)
    events.each {|e| p e }
  end

end