class AddUsernameToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users do |t|
      t.string :username, null:false, limit: 20
    end

    add_index :users, :username, unique: true
  end
end
