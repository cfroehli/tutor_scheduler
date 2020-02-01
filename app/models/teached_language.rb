class TeachedLanguage < ApplicationRecord
  belongs_to :teacher
  belongs_to :language
end
