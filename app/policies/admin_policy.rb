# frozen_string_literal: true

class AdminPolicy < Struct.new(:user, :admin)
  def index?
    user.has_role? :admin
  end

  def impersonate?
    user.has_role? :admin
  end

end
