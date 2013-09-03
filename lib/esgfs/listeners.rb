module EsGfs
	class StatusDatabase
		include Synapse::EventBus::MappingEventListener

	end

	class InMemoryStatusDatabase < StatusDatabase
    class Location < Struct.new(:id, :name)
    end

    class Directory < Struct.new(:id, :name, :path)
    end

    class File < Struct.new(:id, :name, :mime_type, :path)
      attr_reader :locations

      def initialize(id, name, mime_type, path)
        super
        @locations = {}
      end
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
      directory = Directory.new(event.id, event.name, event.path)
      @directories[directory.id] = directory
      @file_map[directory.path] = directory
    end

    map_event FileCreated do |event|
      file = File.new(event.id, event.name, event.mime_type, event.path)
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