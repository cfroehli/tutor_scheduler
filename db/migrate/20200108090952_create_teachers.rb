class CreateTeachers < ActiveRecord::Migration[6.0]
  def change
    create_table :teachers do |t|
      t.references :user, null: false
      t.string :name, null: false, limit: 20
      t.string :image
      t.string :presentation
      t.timestamps
    end

    add_index :teachers, :name, unique: true
  end
end
