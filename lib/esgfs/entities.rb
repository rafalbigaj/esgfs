require 'securerandom'

module EsGfs
  class Error < Synapse::NonTransientError; end
  class LocationAlreadyExistsError < Error; end
  class DirectoryAlreadyExistsError < Error; end
  class FileAlreadyExistsError < Error; end

  class Location
		include Synapse::EventSourcing::AggregateRoot

		attr_reader :name

    def self.create_id(name)
      "Location-#{name}"
    end

		def initialize(id, name)
			apply LocationCreated.new id, name
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

    def initialize(name, owner, parent=nil)
      pre_initialize
			path = parent ? ::File.join(parent.path, name) : name
      apply DirectoryCreated.new name, name, owner, path
    end

    def add_file(name, mime_type)
       file_id = SecureRandom.uuid
       path = ::File.join(self.path, name)
       file = File.new(file_id, self.id, name, mime_type, path)
       apply FileAdded.new(file_id, name)
       file
    end

    def delete_file(file)
      file.delete
      apply FileRemoved.new(file.id, file.name)
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

    map_event FileRemoved do |event|
			@files.delete(event.name)
		end

		map_event SubDirectoryAdded do |event|
			raise DirectoryAlreadyExistsError if @directories.has_key?(event.name)
			@directories[event.name] = event.id
		end
  end

  class File
    include Synapse::EventSourcing::AggregateRoot

    attr_reader :id, :directory_id, :name, :mime_type, :path

		child_entity :file_locations

    def initialize(id, directory_id, name, mime_type, path)
			pre_initialize
      apply FileCreated.new(id, directory_id, name, mime_type, path)
    end

    def delete
      apply FileDeleted.new(id)
    end

		def link_location(location_id, path)
			apply FileLocationLinked.new(self.id, location_id, path)
		end

		def unlink_location(location_id)
			apply FileLocationUnlinked.new(self.id, location_id)
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
      @path = event.path
    end

    map_event FileDeleted do |_|
      mark_deleted
    end

		map_event FileLocationLinked do |event|
			@file_locations << FileLocation.new(event.location_id, event.path)
		end

		map_event FileLocationUnlinked do |event|
			@file_locations.delete_if {|e| e.location_id == event.location_id}
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