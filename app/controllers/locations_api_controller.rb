class LocationsApiController < ApiController
  def create
    send_command(EsGfs::CreateLocation, params[:name]) do |location_id|
      location = status_database.locations[location_id]
      location.to_json
    end
  end

  def status
    if (name = params[:name])
      location_id = EsGfs::Location.create_id(name)
      render :json => status_database.locations[location_id].to_json
    else
      render :json => status_database.locations.to_json
    end
  end

  # TODO: debug only - remove me
  depends_on :event_store
  def events
    render :json => event_store.read_events(:location, "main").to_a.size.to_json
  end
end