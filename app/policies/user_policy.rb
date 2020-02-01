class UserPolicy < ApplicationPolicy
  def impersonate?
    @user.admin?
  end
end
