# frozen_string_literal: true

class Language < ApplicationRecord
  validates :code, uniqueness: { case_sensitive: false }, length: { is: 2 }
  validates :name, uniqueness: { case_sensitive: false }, length: { maximum: 64 }

  has_many :teached_languages, dependent: :destroy
  has_many :teachers, through: :teached_languages

  has_many :courses, dependent: :destroy
end
