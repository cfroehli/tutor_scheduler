class CreateCourses < ActiveRecord::Migration[6.0]
  def change
    create_table :courses do |t|
      t.references :teacher, foreign_key: true, null: false
      t.datetime   :time_slot, null: false
      t.references :language, foreign_key: true, required: false, default: nil
      t.references :student, foreign_key: {to_table: 'users'}, required: false, default: nil
      t.string     :zoom_url, null: false
      t.timestamps
    end
    add_index :courses, [:teacher_id, :time_slot], unique: true
  end
end
