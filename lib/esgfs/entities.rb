require 'securerandom'

module EsGfs
	class Directory
		include Synapse::EventSourcing::AggregateRoot

		attr_reader :name, :owner, :files

		child_entity :files

		def initialize(name, owner)
			pre_initialize
			apply DirectoryCreated.new name, name, owner
		end

		def add_file(name, mime_type)
			file_id = SecureRandom.uuid
			apply FileCreated.new(file_id, name, mime_type)
			file_id
		end

=begin
		def check_in(quantity)
			apply StockCheckedIn.new id, quantity
		end
=end
		protected

		def pre_initialize
			@files = []
		end

		map_event DirectoryCreated do |event|
			@id = event.id
			@name = event.name
			@owner = event.owner
		end

		map_event FileCreated do |event|
			@files.push File.new(event.id, event.name, event.mime_type)
		end
	end

	class File < Struct.new(:id, :name, :mime_type)
		include Synapse::EventSourcing::Entity

	end
end