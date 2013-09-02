require_relative '../test_helper'

class StatusDatabaseTest < ActiveSupport::TestCase
	include Synapse::Configuration::Dependent

	depends_on :gateway
	depends_on :event_bus

	def setup
		Synapse.container.inject_into self
		@listener = EsGfs::InMemoryStatusDatabase.new
		self.event_bus.subscribe @listener
	end

	def test_simple_event

	end

end