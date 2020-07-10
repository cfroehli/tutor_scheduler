# frozen_string_literal: true

class UsersController < ApplicationController
  def courses_history
    @student = User.find(params[:id])
    @courses = Course.with_student(@student).past
  end
end
