# frozen_string_literal: true

class Teacher < ApplicationRecord
  validates :name, uniqueness: true, length: { minimum: 1, maximum: 20 }, format: /\A[a-zA-Z0-9_ .\-]+\z/

  belongs_to :user

  has_many :teached_languages, -> { active }, inverse_of: :teacher
  has_many :languages, through: :teached_languages

  has_many :courses

  mount_uploader :image, ProfileImageUploader

  def add_language(language_id)
    language = Language.find(language_id)
    teached_language = TeachedLanguage.find_by(teacher: self, language: language)
    if teached_language
      { info: "Language #{language.name} already available for teacher #{name}." }
    else
      self.teached_languages.create(language: language)
      { success: "Language #{language.name} added to teacher #{name}." }
    end
  end
end
