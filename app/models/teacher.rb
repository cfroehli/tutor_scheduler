class Teacher < ApplicationRecord
  # TODO add db constraint
  # validates :courses, uniqueness: { scope: :teacher_id, message: 'This profile already exist' }
  # validates :name, uniqueness: true
  
  belongs_to :user

  has_many :teached_languages, -> { active }
  has_many :languages, through: :teached_languages
  
  has_many :courses

  mount_uploader :image, ProfileImageUploader
end
