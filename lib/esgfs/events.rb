module EsGfs
	class DirectoryCreated < Struct.new(:id, :name, :owner)
	end

	class FileCreated < Struct.new(:id, :directory_id, :name, :mime_type)
  end

  class FileAdded < Struct.new(:id, :name)
  end

	class FileAlreadyExists < Struct.new(:id, :directory_id, :name)
	end

	class LocationCreated < Struct.new(:id, :name)
  end
end