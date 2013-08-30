require_relative '../test_helper'

class DirectoryTest < ActiveSupport::TestCase
	include Synapse::Configuration::Dependent

	depends_on :gateway
	depends_on :event_store
	depends_on :file_repository

	def setup
		Synapse.container.inject_into self
	end

	def test_create
		command = EsGfs::CreateDirectory.new("root", nil)
		directory = gateway.send_and_wait command

		assert_kind_of EsGfs::Directory, directory
		assert_equal "root", directory.name
		assert_equal "root", directory.id
		assert_nil directory.owner
	end

	def test_add_file
		command = EsGfs::CreateDirectory.new("root", nil)
		directory = gateway.send_and_wait command

		command = EsGfs::CreateFile.new(directory.id, "test.txt", "text/plain")
		file_id = gateway.send_and_wait command

		directory = file_repository.load(directory.id)
		assert_equal 1, directory.files.size

		file = directory.files.first
		assert_kind_of EsGfs::File, file
		assert_equal file_id, file.id
		assert_equal "test.txt", file.name
		assert_equal "text/plain", file.mime_type
	end
end