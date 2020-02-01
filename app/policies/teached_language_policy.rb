class TeachedLanguagePolicy < ApplicationPolicy
  def activate?
    @user.admin?
  end

  def deactivate?
    @user.admin?
  end
end
