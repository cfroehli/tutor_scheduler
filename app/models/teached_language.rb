# frozen_string_literal: true

class TeachedLanguage < ApplicationRecord
  belongs_to :teacher
  belongs_to :language

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :status, -> { partition(&:active?) }
end
