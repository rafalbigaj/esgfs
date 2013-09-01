require 'synapse/configuration'
require 'esgfs'

Logging.logger.root.appenders = Logging.appenders.file("log/synapse.log")
Logging.logger.root.level = :debug

Synapse.build_with_defaults do
	# async_command_bus
	# gateway

	es_repository :file_repository do
    use_aggregate_type EsGfs::File
	end

	es_repository :directory_repository do
    use_aggregate_type EsGfs::Directory
	end

	es_repository :location_repository do
    use_aggregate_type EsGfs::Location
	end

	factory :event_store do
		Synapse::EventStore::InMemoryEventStore.new
	end

  # Register your command handler so it can be subscribed to the command bus and get its own
  # dependencies injected upon creation
  factory :directory_command_handler, :tag => :command_handler do
		inject_into EsGfs::DirectoryCommandHandler.new
  end
end
