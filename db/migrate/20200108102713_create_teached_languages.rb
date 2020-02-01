class CreateTeachedLanguages < ActiveRecord::Migration[6.0]
  def change
    create_table :teached_languages do |t|
      t.references :teacher, foreign_key: true
      t.references :language, foreign_key: true
      t.boolean :active, default: false
      t.timestamps
    end
    add_index :teached_languages, [:teacher_id, :language_id], unique: true
  end
end
