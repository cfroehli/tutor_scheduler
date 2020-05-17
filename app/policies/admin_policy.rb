# frozen_string_literal: true

AdminPolicy = Struct.new(:user, :admin) do
  def index?
    user.has_role? :admin
  end

  def impersonate?
    user.has_role? :admin
  end
end
