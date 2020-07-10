# frozen_string_literal: true

class TicketsController < ApplicationController
  def order_cancel
    flash[:success] = 'Your order has been cancelled.'
    redirect_to courses_path
  end

  def order_success
    flash[:success] = 'Your order has been processed.'
    redirect_to courses_path
  end
end
