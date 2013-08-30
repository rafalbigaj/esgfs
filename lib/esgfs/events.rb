module EsGfs
	class DirectoryCreated < Struct.new(:id, :name, :owner)
	end

	class FileCreated < Struct.new(:id, :name, :mime_type)
	end
end