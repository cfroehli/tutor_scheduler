class Course < ApplicationRecord
  belongs_to :teacher
  belongs_to :language, required: false, default: nil
  belongs_to :student, class_name: 'User', required: false, default: nil

  scope :with_teacher, ->(teacher) { where(teacher: teacher) }
  scope :with_language, ->(language) { with_teacher(language.teachers) }
  scope :on_day, ->(year, month, day) { where('time_slot::date = ?', Date.new(year, month, day)) }

  scope :future, ->() { where('time_slot > CURRENT_TIMESTAMP') }

  scope :planned, ->() { future.where.not(student: nil) }

  scope :available, ->() { future.where(student: nil) } do
    def years
      distinct
        .order(:year)
        .pluck(Arel.sql('extract(year from time_slot)::integer as year'))
    end

    def months(year)
      distinct
        .where('extract(year from time_slot) = ?', year)
        .order(:month)
        .pluck(Arel.sql('extract(month from time_slot)::integer as month'))
    end

    def days(year, month)
      distinct
        .where('extract(year from time_slot) = ?', year)
        .where('extract(month from time_slot) = ?', month)
        .order(:day)
        .pluck(Arel.sql('extract(day from time_slot)::integer as day'))
    end
  end
end
