class Course < ApplicationRecord
  belongs_to :teacher
  belongs_to :language, required: false, default: nil
  belongs_to :student, class_name: 'User', required: false, default: nil

  def self.search(options={})
    sql_clause = where(student: options[:student])
    teacher_id = options[:teacher_id]
    if teacher_id
      sql_clause = sql_clause.where(teacher_id: teacher_id)
    end
    date = options[:date]
    if date
      sql_clause = sql_clause.where("time_slot::date = ?", date)
    end
    if options[:order_by_time_slot]
      sql_clause.order(time_slot: options[:order_by_time_slot])
    end
    sql_clause
  end

  scope :future, ->() { where('time_slot > CURRENT_TIMESTAMP') }

  scope :planned, ->() { future.where.not(student: nil) }

  scope :available, ->() { future.where(student: nil) } do
    def years
      distinct
        .order(:year)
        .pluck(Arel.sql('extract(year from time_slot)::integer as year'))
    end

    def months(year)
      where('extract(year from time_slot) = ?', year)
        .distinct
        .order(:month)
        .pluck(Arel.sql('extract(month from time_slot)::integer as month'))
    end

    def days(year, month)
      where('extract(year from time_slot) = ?', year)
        .where('extract(month from time_slot) = ?', month)
        .distinct
        .order(:day)
        .pluck(Arel.sql('extract(day from time_slot)::integer as day'))
    end
  end
end
