class TeacherPolicy < ApplicationPolicy
  def update?
    @record.user.id == @user.id || @user.has_role? :admin
  end

  def add_language?
    @user.has_role? :admin
  end
end
