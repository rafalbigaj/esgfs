module EsGfs
	class LocationCreated < Struct.new(:id, :name)
	end

	class DirectoryCreated < Struct.new(:id, :name, :owner, :path)
	end

	class SubDirectoryAdded < Struct.new(:id, :name)
	end

	class FileCreated < Struct.new(:id, :directory_id, :name, :mime_type)
  end

  class FileAdded < Struct.new(:id, :name)
  end

	class FileAlreadyExists < Struct.new(:id, :directory_id, :name)
	end

	class FileLocationLinked < Struct.new(:location_id, :path)
  end
end