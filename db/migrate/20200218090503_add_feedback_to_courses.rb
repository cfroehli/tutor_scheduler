class AddFeedbackToCourses < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :feedback, :text
  end
end
