require_relative '../test_helper'

class LocationTest < ActiveSupport::TestCase
	include Synapse::Configuration::Dependent

	depends_on :gateway
	depends_on :event_store
	depends_on :location_repository

	def setup
		Synapse.container.inject_into self
    event_store.clear
	end

	def test_create
		command = EsGfs::CreateLocation.new("main")
		location_id = gateway.send_and_wait command
    assert_equal "main", location_id

    events = event_store.read_events('Location', location_id).to_a.map(&:payload)

    assert_equal 1, events.size
    event = events[0]
    assert_kind_of EsGfs::LocationCreated, event
    assert_equal location_id, event.id
    assert_equal "main", event.name
	end
end