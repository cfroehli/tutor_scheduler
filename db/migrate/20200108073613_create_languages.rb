class CreateLanguages < ActiveRecord::Migration[6.0]
  def change
    create_table :languages do |t|
      t.column(:code, 'char(2)')
      t.string :name
    end
  end
end
