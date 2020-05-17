# frozen_string_literal: true

class AddStripePlanIdToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :stripe_plan_id
      t.string :stripe_subscription_id
    end
  end
end
