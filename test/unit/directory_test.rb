require_relative '../test_helper'

class DirectoryTest < ActiveSupport::TestCase
	include Synapse::Configuration::Dependent

	depends_on :gateway
	depends_on :event_store
	depends_on :file_repository

	def setup
		Synapse.container.inject_into self
    event_store.clear
	end

	def test_create
		command = EsGfs::CreateDirectory.new("root", nil)
		directory_id = gateway.send_and_wait command
    assert_equal "root", directory_id

    events = event_store.read_events('Directory', directory_id).to_a.map(&:payload)

    assert_equal 1, events.size
    event = events[0]
    assert_kind_of EsGfs::DirectoryCreated, event
    assert_equal directory_id, event.id
    assert_equal "root", event.name
    assert_nil event.owner
	end

	def test_create_subdirectory
		command = EsGfs::CreateDirectory.new("root", nil)
		directory_id = gateway.send_and_wait command

		command = EsGfs::CreateDirectory.new("a", nil, directory_id)
		a_directory_id = gateway.send_and_wait command

		command = EsGfs::CreateDirectory.new("b", nil, a_directory_id)
		b_directory_id = gateway.send_and_wait command

		events = event_store.read_events(:directory, b_directory_id).to_a.map(&:payload)
		assert_kind_of EsGfs::DirectoryCreated, events[0]

		event = events[0]
		assert_equal b_directory_id, event.id
		assert_equal "b", event.name
		assert_equal "root/a/b", event.path

		events = event_store.read_events(:directory, a_directory_id).to_a.map(&:payload)
		assert_kind_of EsGfs::DirectoryCreated, events[0]
		assert_kind_of EsGfs::SubDirectoryAdded, events[1]

		event = events[1]
		assert_equal b_directory_id, event.id
		assert_equal "b", event.name
	end

	def test_add_file
		command = EsGfs::CreateDirectory.new("root", nil)
		directory_id = gateway.send_and_wait command

		command = EsGfs::CreateFile.new(directory_id, "test.txt", "text/plain")
		file_id = gateway.send_and_wait command

    events = event_store.read_events(:file, file_id).to_a.map(&:payload)
    assert_equal 1, events.size
    assert_kind_of EsGfs::FileCreated, events[0]

		file_event = events[0]
		assert_equal file_id, file_event.id
		assert_equal "test.txt", file_event.name
		assert_equal "text/plain", file_event.mime_type

		assert_equal 2, event_store.read_events(:directory, directory_id).to_a.size

		assert_raise Synapse::Command::CommandExecutionError do
			command = EsGfs::CreateFile.new(directory_id, "test.txt", "text/plain")
			gateway.send_and_wait command
		end

		assert_equal 2, event_store.read_events(:directory, directory_id).to_a.size, "No event should be added after exception"
	end

	def test_add_file_location
		command = EsGfs::CreateLocation.new("main")
		location_id = gateway.send_and_wait command

		command = EsGfs::CreateDirectory.new("root", nil)
		directory_id = gateway.send_and_wait command

		command = EsGfs::CreateFile.new(directory_id, "test.txt", "text/plain")
		file_id = gateway.send_and_wait command

		command = EsGfs::LinkFileLocation.new(file_id, location_id, "/home/repository/main/test.txt")
		gateway.send_and_wait command

		events = event_store.read_events(:file, file_id).to_a.map(&:payload)
		assert_equal 2, events.size
		assert_kind_of EsGfs::FileCreated, events[0]
		assert_kind_of EsGfs::FileLocationLinked, events[1]

		event = events[1]
		assert_equal location_id, event.location_id
		assert_equal "/home/repository/main/test.txt", event.path
	end
end