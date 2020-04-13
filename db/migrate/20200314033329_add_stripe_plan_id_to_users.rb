# frozen_string_literal: true

class AddStripePlanIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :stripe_plan_id, :string
    add_column :users, :stripe_subscription_id, :string
  end
end
