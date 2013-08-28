class InventoryItem
  include Synapse::EventSourcing::AggregateRoot

  def initialize(id, description)
    apply InventoryItemCreated.new id, description
  end

  def check_in(quantity)
    apply StockCheckedIn.new id, quantity
  end

  map_event InventoryItemCreated do |event|
    @id = event.id
  end

  map_event StockCheckedIn do |event|
    @stock = @stock + event.quantity
  end
end