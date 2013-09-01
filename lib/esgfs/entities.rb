require 'securerandom'

module EsGfs
  class Directory
    include Synapse::EventSourcing::AggregateRoot

    attr_reader :name, :owner, :files

    child_entity :files

    class FileAlreadyExistsError < Synapse::NonTransientError; end

    def initialize(name, owner)
      pre_initialize
      apply DirectoryCreated.new name, name, owner
    end

    def add_file(name, mime_type)
      unless (existing_file_id = @files[name])
        file_id = SecureRandom.uuid
        file = File.new(file_id, self.id, name, mime_type)
        apply FileAdded.new(file_id, name)
        file
      else # File already exist
        raise FileAlreadyExistsError
      end
    end

    protected

    def pre_initialize
      @files = {}
    end

    map_event DirectoryCreated do |event|
      @id = event.id
      @name = event.name
      @owner = event.owner
    end

    map_event FileAdded do |event|
      @files[event.name] = event.id
    end
  end

  class File < Struct.new(:id, :name, :mime_type)
    include Synapse::EventSourcing::AggregateRoot

    def initialize(id, directory_id, name, mime_type)
      apply FileCreated.new(id, directory_id, name, mime_type)
    end

    protected

    map_event FileCreated do |event|
      @id = event.id
      @directory_id = event.directory_id
      @name = event.name
      @mime_type = event.mime_type
    end
  end

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
end