module EsGfs
	class StatusDatabase
		include Synapse::EventBus::MappingEventListener


	end

	class InMemoryStatusDatabase < StatusDatabase

	end
end