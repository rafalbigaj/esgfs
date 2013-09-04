require 'esgfs/configuration'
require 'esgfs/commands'
require 'esgfs/events'
require 'esgfs/command_handler'
require 'esgfs/entities'
require 'esgfs/listeners'


module Synapse
  module Configuration
    class ContainerBuilder
      builder :in_memory_status_database, EsGfs::InMemoryStatusDatabaseDefinitionBuilder
    end
  end
end


class Synapse::Command::CommandExecutionError
  def message
    "#{cause.class.name}: #{cause.message}"
  end
end

Synapse::EventStore::Mongo::MongoEventStore.class_eval do
	def clear
		@template.event_collection.drop
		@template.snapshot_collection.drop
	end
end