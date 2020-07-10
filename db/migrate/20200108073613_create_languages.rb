# frozen_string_literal: true

class CreateLanguages < ActiveRecord::Migration[6.0]
  def change
    create_table :languages do |t|
      t.column(:code, 'char(2)')
      t.string :name
      t.timestamps
    end
    add_index :languages, :code, unique: true
    add_index :languages, :name, unique: true
  end
end
