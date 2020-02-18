class AddTicketsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :tickets, :integer, null: false, default: 1
  end
end
