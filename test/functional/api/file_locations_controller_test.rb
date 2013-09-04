require_relative '../../test_helper'

class FileLocationsControllerTest < ActionController::TestCase
	include EsGfs::Testing

	tests Api::FileLocationsController

	test "create" do
		location_id = send_command(EsGfs::CreateLocation, "main")
		directory_id = send_command(EsGfs::CreateDirectory, "repository", nil)
		file_id = send_command(EsGfs::CreateFile, directory_id, "test.txt", "text/plain")

		post :create, :file_id => file_id, :location_id => location_id, :path => "/home/public/repository/text.txt"
		assert_response :success
		assert_equal 'application/json', response.content_type
		locations = {}
		locations[location_id] = "/home/public/repository/text.txt"
		pattern = {
						name: 'test.txt',
						mime_type: 'text/plain',
						directory_id: directory_id,
						locations: locations
		}.ignore_extra_keys!
		assert_json_match pattern, response.body
	end

end