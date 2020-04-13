# frozen_string_literal: true

class AddFeedbackToCourses < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :feedback, :text
  end
end
