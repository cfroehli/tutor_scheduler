# frozen_string_literal: true

class TeachedLanguagePolicy < ApplicationPolicy
  def activate?
    user.has_role? :admin
  end

  def deactivate?
    user.has_role? :admin
  end
end
