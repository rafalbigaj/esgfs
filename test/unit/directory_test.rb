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

    command = EsGfs::CreateFile.new(directory_id, "test.txt", "text/plain")
    file_id = gateway.send_and_wait command

    # assert_nil file_id
    p event_store
	end
end