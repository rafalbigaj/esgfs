module Api
	class FileLocationsController < BaseController
		def create
			file = status_database.files[params[:file_id]]
			raise "File '#{params[:file_id]}' not found" unless file

			send_command(EsGfs::LinkFileLocation, file.id, params[:location_id], params[:path]) do
				file
			end
		end
	end
end