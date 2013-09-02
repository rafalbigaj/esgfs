module EsGfs
	class CreateLocation < Struct.new(:name)
	end

	class CreateDirectory < Struct.new(:name, :owner, :directory_id)
		def initialize(name, owner, directory_id=nil)
			super
		end
	end

	class CreateFile < Struct.new(:directory_id, :name, :mime_type)
	end

	class LinkFileLocation < Struct.new(:file_id, :location_id, :path)
	end
end