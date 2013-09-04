module Api
	class FilesController < BaseController
		def create
			parent_path, name = ::File.split(params[:path])
			ext = File.extname(name)[1..-1]
			parent = status_database.file_map[parent_path]
			raise "Directory '#{parent_path}' not found" unless parent
			raise "'#{parent_path}' is not a directory" unless parent.directory?
			mime_type = params[:mime_type] || Mime::Type.lookup_by_extension(ext)

			send_command(EsGfs::CreateFile, parent.id, name, mime_type.to_s) do |id|
				status_database.files[id]
			end
		end
	end
end