# frozen_string_literal: true

class AddContentToCourses < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :content, :text
  end
end
