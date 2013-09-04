require 'test_helper'
require 'rails/performance_test_help'

class GfsTest < ActionDispatch::IntegrationTest
	include EsGfs::Testing

	def test_create_structure
		post "/api/locations", name: 'main'
		assert_response :success
		@location_id = ActiveSupport::JSON.decode(response.body)['id']
		assert_not_nil @location_id
		@entries = 0
		create_directory_structure Rails.root.to_s, File.dirname(Rails.root)
		puts "Created #{@entries} directories and files"
	end

	protected

	def create_directory_structure(path, root_path)
		@entries += 1
		root_path ||= path
		gfs_path = path[root_path.length+1..-1]
		post "/api/directories", :path => gfs_path
		assert_response :success
		Dir.glob(File.join(path, "*")).each do |sub_path|
			if sub_path[0] != '.'
				if File.directory?(sub_path)
					create_directory_structure sub_path, root_path
				else
					create_file sub_path, root_path
				end
			end
		end
	end

	def create_file(path, root_path)
		@entries += 1
		gfs_path = path[root_path.length+1..-1]
		post "/api/files", :path => gfs_path
		assert_response :success
		file_id = ActiveSupport::JSON.decode(response.body)['id']
		assert_not_nil file_id
		post "/api/files/#{file_id}/locations", :path => gfs_path, :location_id => @location_id
		assert_response :success
	end
end