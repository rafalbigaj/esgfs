Synapse.build_with_defaults do
  mongo_event_store do
    use_client Mongo::MongoClient.new
  end

  es_repository :item_repository do
    use_aggregate_type InventoryItem
  end

  # Register your command handler so it can be subscribed to the command bus and get its own
  # dependencies injected upon creation
  factory :item_command_handler, :tag => :command_handler do
    handler = InventoryItemCommandHandler.new
    handler.repository = resolve :item_repository

    handler
  end
end