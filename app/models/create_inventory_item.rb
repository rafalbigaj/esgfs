class CreateInventoryItem
  attr_reader :id, :description

  def initialize(id, description)
    @id = id
    @description = description
  end
end