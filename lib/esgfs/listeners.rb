module EsGfs
	class StatusDatabase
		include Synapse::EventBus::MappingEventListener

	end

	class InMemoryStatusDatabase < StatusDatabase
    class Location < Struct.new(:id, :name)
    end

    class Directory
			attr_reader :id, :name, :owner, :parent_id, :path

			def initialize(id, name, owner, parent)
				@id = id
				@name = name
				@owner = owner
				@parent_id = parent.try(:id)
				@path = parent ? ::File.join(parent.path, name) : name
			end

			def directory?; true end
			def file?; false end
    end

    class File
      attr_reader :id, :directory_id, :name, :mime_type, :path, :locations

      def initialize(id, name, mime_type, directory)
        @id = id
				@name = name
				@mime_type = mime_type
        @directory_id = directory.id
				@path = ::File.join(directory.path, name)
				@locations = {}
      end

			def directory?; false end
			def file?; true end
    end

    attr_reader :locations, :directories, :files
    attr_reader :file_map

    def initialize
      @locations = {}
      @directories = {}
      @files = {}
      @file_map = {}
    end

    map_event LocationCreated do |event|
      @locations[event.id] = Location.new(event.id, event.name)
    end

    map_event DirectoryCreated do |event|
			parent = @directories[event.parent_id] if event.parent_id
			raise "Parent directory '#{event.parent_id}' not found" if event.parent_id && !parent
      directory = Directory.new(event.id, event.name, event.owner, parent)
      @directories[directory.id] = directory
      @file_map[directory.path] = directory
    end

    map_event FileCreated do |event|
			directory = @directories[event.directory_id]
			raise "Directory '#{event.directory_id}' not found" unless directory
      file = File.new(event.id, event.name, event.mime_type, directory)
      @files[file.id] = file
      @file_map[file.path] = file
    end

    map_event FileLocationLinked do |event|
      file = @files[event.file_id]
      file.locations[event.location_id] = event.path
    end

    map_event FileLocationUnlinked do |event|
      file = @files[event.file_id]
      file.locations.delete(event.location_id)
    end
	end
end