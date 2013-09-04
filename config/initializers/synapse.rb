require 'synapse/configuration'
require 'esgfs'

Logging.logger.root.appenders = Logging.appenders.file("log/synapse.log")
Logging.logger.root.level = :debug

Synapse.build_with_defaults do
	# mongo
	#async_command_bus do
	#	use_pool_options size: 4, non_block: true
	#end

	mongo_event_store do
		use_client Mongo::MongoClient.new
	end

	# memory
	#factory :event_store do
	#	Synapse::EventStore::InMemoryEventStore.new
	#end

	snapshot_taker
	interval_snapshot_policy do
		use_threshold 30
	end

	factory :es_cache do
		ActiveSupport::Cache::MemoryStore.new
	end


	es_repository :file_repository do
    use_aggregate_type EsGfs::File
		use_cache :es_cache
	end

	es_repository :directory_repository do
    use_aggregate_type EsGfs::Directory
		use_cache :es_cache
	end

	es_repository :location_repository do
    use_aggregate_type EsGfs::Location
		use_cache :es_cache
	end

  in_memory_status_database do

  end

  # Register your command handler so it can be subscribed to the command bus and get its own
  # dependencies injected upon creation
  factory :directory_command_handler, :tag => :command_handler do
		inject_into EsGfs::DirectoryCommandHandler.new
  end
end
