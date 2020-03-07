class Ticket < ApplicationRecord
  belongs_to :user

  scope :valid, -> { where.not(remaining: 0).where("COALESCE(expiration, 'infinity')::date >= ?", Date.today) }
end
