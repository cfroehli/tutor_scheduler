class CreateTickets < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :tickets, :old_tickets

    create_table :tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :expiration, default: nil
      t.integer :initial_count, default: 0, null: false
      t.integer :remaining, default: 0, null: false

      t.timestamps
    end

    User.all.each do |user|
      if user.old_tickets > 0
        ticket = user.tickets.new(initial_count: user.tickets, remaining: user.tickets)
        ticket.save
      end
    end

    remove_column :users, :old_tickets

  end
end
