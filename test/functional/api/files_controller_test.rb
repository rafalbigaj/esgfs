require_relative '../../test_helper'

class FilesControllerTest < ActionController::TestCase
	include EsGfs::Testing

	tests Api::FilesController

	test "create" do
		root_id = send_command(EsGfs::CreateDirectory, "root", nil)

		post :create, :path => "root/test.txt"
		assert_response :success
		assert_equal 'application/json', response.content_type
		pattern = {
						name: 'test.txt',
						mime_type: 'text/plain',
						directory_id: root_id
		}.ignore_extra_keys!
		assert_json_match pattern, response.body
	end

end