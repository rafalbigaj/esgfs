module Api
	class DirectoriesController < BaseController
		def create
			parent_path, name = ::File.split(params[:path])
			if parent_path != '.'
				parent = status_database.file_map[parent_path]
				raise "Directory '#{parent_path}' not found" unless parent
				raise "'#{parent_path}' is not a directory" unless parent.directory?
			end
			send_command(EsGfs::CreateDirectory, name, params[:owner], parent.try(:id)) do |id|
				status_database.directories[id]
			end
		end
	end
end