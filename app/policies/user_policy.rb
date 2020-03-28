class UserPolicy < ApplicationPolicy
  def impersonate?
    @user.has_role? :admin
  end
end
