class InventoryItemCommandHandler
  include Synapse::Command::MappingCommandHandler

  attr_accessor :repository

  map_command CreateInventoryItem do |command|
    item = InventoryItem.new command.id, command.description
    @repository.add item
  end

  map_command CheckInStock do |command|
    item = @repository.load command.id
    item.check_in command.quantity
  end
end