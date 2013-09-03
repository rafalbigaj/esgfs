module EsGfs
  class DirectoryCommandHandler
    include Synapse::Command::MappingCommandHandler
    include Synapse::Configuration::Dependent

    depends_on :file_repository
    depends_on :directory_repository
    depends_on :location_repository
    depends_on :event_store

		map_command CreateLocation do |command|
			location_id = Location.create_id(command.name)
      existing_location = location_repository.load(location_id) rescue nil
      raise LocationAlreadyExistsError, "Location with name '#{existing_location.name}' already exists" if existing_location

      location = Location.new(location_id, command.name)
			location_repository.add location
			location.id
		end

    map_command CreateDirectory do |command|
			parent = directory_repository.load(command.directory_id) if command.directory_id
			directory = Directory.new(command.name, command.owner, parent)
      directory_repository.add directory
			parent.add_sub_directory directory.id, directory.name if parent
      directory.id
    end

    map_command CreateFile do |command|
      directory = directory_repository.load(command.directory_id)
      file = directory.add_file(command.name, command.mime_type)
      file_repository.add file if file
      file.try(:id)
    end

    map_command DeleteFile do |command|
      file = file_repository.load(command.id)
      directory = directory_repository.load(file.directory_id)
      directory.delete_file file
    end

    map_command LinkFileLocation do |command|
			file = file_repository.load(command.file_id)
			file.link_location command.location_id, command.path
    end

    map_command UnlinkFileLocation do |command|
			file = file_repository.load(command.file_id)
			file.unlink_location command.location_id
    end

  end
end