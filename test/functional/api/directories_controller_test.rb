require_relative '../../test_helper'

class DirectoriesControllerTest < ActionController::TestCase
	include EsGfs::Testing

	tests Api::DirectoriesController

	test "create" do
		post :create, :path => "root"
		assert_response :success
		assert_equal 'application/json', response.content_type
		pattern = {
						id: :id,
						name: 'root',
						owner: nil,
						parent_id: nil
		}.ignore_extra_keys!
		matcher = assert_json_match(pattern, response.body)
		root_id = matcher.captures[:id]

		post :create, :path => "root/a"
		assert_response :success
		assert_equal 'application/json', response.content_type
		pattern = {
						id: :id,
						name: 'a',
						owner: nil,
						parent_id: root_id
		}.ignore_extra_keys!
		matcher = assert_json_match(pattern, response.body)
		a_id = matcher.captures[:id]
	end

end