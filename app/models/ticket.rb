# frozen_string_literal: true

class Ticket < ApplicationRecord
  belongs_to :user

  scope :valid, -> { where.not(remaining: 0).where("COALESCE(expiration, 'infinity')::date >= ?", Time.zone.today) }
end
