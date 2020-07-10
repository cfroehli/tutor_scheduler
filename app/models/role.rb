# frozen_string_literal: true

class Role < ApplicationRecord
  # has_many :through not yet supported https://github.com/RolifyCommunity/rolify/issues/318
  has_and_belongs_to_many :users, join_table: :users_roles # rubocop:disable Rails/HasAndBelongsToMany

  belongs_to :resource,
             polymorphic: true,
             optional: true

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  scopify
end
