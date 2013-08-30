module EsGfs
	class DirectoryCommandHandler
		include Synapse::Command::MappingCommandHandler
		include Synapse::Configuration::Dependent

		depends_on :file_repository
		depends_on :event_store

		map_command CreateDirectory do |command|
			Directory.new(command.name, command.owner).tap do |directory|
				file_repository.add directory
			end
		end

		map_command CreateFile do |command|
			directory = file_repository.load(command.directory_id)
			directory.add_file(command.name, command.mime_type)
		end

=begin
		map_command CheckInStock do |command|
			item = item_repository.load(command.id)
			item.check_in command.quantity
		end
=end
	end
end