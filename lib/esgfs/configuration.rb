module EsGfs
  class InMemoryStatusDatabaseDefinitionBuilder < Synapse::Configuration::DefinitionBuilder

    protected

    # @return [undefined]
    def populate_defaults
      identified_by :status_database

      use_factory do
        status_database = InMemoryStatusDatabase.new
        event_bus = resolve(:event_bus)
        event_bus.subscribe status_database
        status_database
      end
    end
  end
end

