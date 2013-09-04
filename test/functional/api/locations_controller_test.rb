require_relative '../../test_helper'

class LocationsControllerTest < ActionController::TestCase
	include EsGfs::Testing

	tests Api::LocationsController

	test "create" do
		post :create, :name => "main"
		assert_response :success
		assert_equal 'application/json', response.content_type
		pattern = {
						name: 'main'
		}.ignore_extra_keys!
		assert_json_match pattern, response.body
	end

end