require 'securerandom'

module EsGfs
	class Location
		include Synapse::EventSourcing::AggregateRoot

		attr_reader :name

		def initialize(name)
			apply LocationCreated.new name, name
		end

		map_event LocationCreated do |event|
			@id = event.id
			@name = event.name
		end
	end

  class Directory
    include Synapse::EventSourcing::AggregateRoot

    attr_reader :name, :owner, :path, :files, :directories

    child_entity :files

    class FileAlreadyExistsError < Synapse::NonTransientError; end
    class DirectoryAlreadyExistsError < Synapse::NonTransientError; end

    def initialize(name, owner, parent=nil)
      pre_initialize
			path = parent ? ::File.join(parent.path, name) : name
      apply DirectoryCreated.new name, name, owner, path
    end

    def add_file(name, mime_type)
       file_id = SecureRandom.uuid
       file = File.new(file_id, self.id, name, mime_type)
       apply FileAdded.new(file_id, name)
       file
		end

		def add_sub_directory(id, name)
			apply SubDirectoryAdded.new(id, name)
		end

    protected

    def pre_initialize
      @files = {}
			@directories = {}
    end

    map_event DirectoryCreated do |event|
      @id = event.id
      @name = event.name
      @owner = event.owner
      @path = event.path
    end

    map_event FileAdded do |event|
			raise FileAlreadyExistsError if @files.has_key?(event.name)
      @files[event.name] = event.id
		end

		map_event SubDirectoryAdded do |event|
			raise DirectoryAlreadyExistsError if @directories.has_key?(event.name)
			@directories[event.name] = event.id
		end
  end

  class File < Struct.new(:id, :name, :mime_type)
    include Synapse::EventSourcing::AggregateRoot

		child_entity :file_locations

    def initialize(id, directory_id, name, mime_type)
			pre_initialize
      apply FileCreated.new(id, directory_id, name, mime_type)
		end

		def link_location(location_id, path)
			apply FileLocationLinked.new(location_id, path)
		end

    protected

		def pre_initialize
			@file_locations = []
		end

    map_event FileCreated do |event|
      @id = event.id
      @directory_id = event.directory_id
      @name = event.name
      @mime_type = event.mime_type
		end

		map_event FileLocationLinked do |event|
			@file_locations << FileLocation.new(event.location_id, event.path)
		end
  end

	class FileLocation < Struct.new(:location_id, :path)
		include Synapse::EventSourcing::Entity

		def initialize(location_id, path)
			@location_id = location_id
			@path = path
		end
	end
end