class TicketsController < ApplicationController
  def new
    @products = Stripe::SKU.list().map do |sku|
      { id: sku.id, name: sku.attributes.name, price: sku.price, hours: sku.attributes.lot_size }
    end
  end

  def order_cancel
    flash[:success] = "Your order has been cancelled."
    redirect_to courses_path
  end

  def order_success
    flash[:success] = "Your order has been processed."
    redirect_to courses_path
  end
end
