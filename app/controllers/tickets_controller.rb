class TicketsController < ApplicationController
  def create
    current_user.tickets += 1
    current_user.save

    flash[:success] = "User #{current_user} now have #{current_user.tickets} tickets"
    redirect_to courses_path
  end
end
