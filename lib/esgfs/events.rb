module EsGfs
	class LocationCreated < Struct.new(:id, :name)
	end

	class DirectoryCreated < Struct.new(:id, :name, :owner, :parent_id)
	end

	class SubDirectoryAdded < Struct.new(:id, :name)
	end

	class FileCreated < Struct.new(:id, :directory_id, :name, :mime_type)
  end

  class FileDeleted < Struct.new(:id)
  end

  class FileAdded < Struct.new(:id, :name)
  end

  class FileRemoved < Struct.new(:id, :name)
  end

	class FileLocationLinked < Struct.new(:file_id, :location_id, :path)
  end

  class FileLocationUnlinked < Struct.new(:file_id, :location_id)
  end
end