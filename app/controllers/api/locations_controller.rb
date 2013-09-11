module Api
	class LocationsController < BaseController
		def new
    end

    def create
			send_command(EsGfs::CreateLocation, params[:name]) do |id|
				status_database.locations[id]
			end
		end

		def show
			location_id = EsGfs::Location.create_id(params[:id])
			render :json => status_database.locations[location_id]
		end

		def index
			render :json => status_database.locations
		end
	end
end