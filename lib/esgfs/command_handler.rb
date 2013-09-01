module EsGfs
  class DirectoryCommandHandler
    include Synapse::Command::MappingCommandHandler
    include Synapse::Configuration::Dependent

    depends_on :file_repository
    depends_on :directory_repository
    depends_on :location_repository
    depends_on :event_store

    map_command CreateDirectory do |command|
      directory = Directory.new(command.name, command.owner)
      directory_repository.add directory
      directory.id
    end

    map_command CreateFile do |command|
      directory = directory_repository.load(command.directory_id)
      file = directory.add_file(command.name, command.mime_type)
      file_repository.add file if file
      file.try(:id)
    end

    map_command CreateLocation do |command|
      location = Location.new(command.name)
      location_repository.add location
      location.id
    end

=begin
		map_command CheckInStock do |command|
			item = item_repository.load(command.id)
			item.check_in command.quantity
		end
=end
  end
end