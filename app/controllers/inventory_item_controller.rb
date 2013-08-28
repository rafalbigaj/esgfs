class InventoryItemController < ApplicationController
  depends_on :gateway

  def create
    command = CreateInventoryItem.new params[:sku], params[:description]
    gateway.send command
  end
end