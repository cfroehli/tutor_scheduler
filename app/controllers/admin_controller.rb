# frozen_string_literal: true

class AdminController < ApplicationController
  def index
    authorize :admin
  end

  def impersonate
    authorize :admin
    user = User.find(params[:id])
    impersonate_user(user)
    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_to root_path
  end
end
