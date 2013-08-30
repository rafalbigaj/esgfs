module EsGfs
	class CreateLocation < Struct.new(:name)
	end

	class CreateDirectory < Struct.new(:name, :owner)
	end

	class CreateFile < Struct.new(:directory_id, :name, :mime_type)
	end

	class CreateFileLocation < Struct.new(:file_id, :location_id, :path)
	end
end