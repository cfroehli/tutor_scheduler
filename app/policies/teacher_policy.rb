class TeacherPolicy < ApplicationPolicy
  def update?
    @record.user.id == @user.id || @user.admin?
  end

  def add_language?
    @user.admin?
  end
end
