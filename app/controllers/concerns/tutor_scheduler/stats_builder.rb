module TutorScheduler
  module StatsBuilder
    extend ActiveSupport::Concern

    private

    def build_stats(signed_up_stats, open_stats, key)
      open_count = open_stats[key] || 0
      signed_up_count = signed_up_stats[key] || 0
      total_count = open_count + signed_up_count
      return { text: nil, ratio: -1 } if total_count.zero?

      ratio = 100.0 * (signed_up_count.to_f / total_count)
      { text: "#{signed_up_count} / #{total_count}<br/>#{ratio.round(2)}%", ratio: ratio }
    end

    def build_array_stats(signed_up, open, rows, columns)
      open_stats = open.count
      signed_up_stats = signed_up.count
      rows.map do |row_id, row_name|
        [row_name] + columns.map { |col_id| build_stats(signed_up_stats, open_stats, [row_id, col_id]) }
      end
    end

    def build_details_stats(courses, columns)
      open_stats = courses.open.count
      signed_up_stats = courses.signed_up.count
      columns.map { |col_id| build_stats(signed_up_stats, open_stats, col_id) }
    end

    def stats(courses, group_by, group_range)
      courses = courses.group(group_by)
      [build_details_stats(courses, group_range)]
    end

    def monthly_stats(courses)
      stats(courses, 'extract(day from time_slot)::integer', 1..31)
    end

    def weekly_stats(courses)
      stats(courses, 'extract(dow from time_slot)::integer', 0..6)
    end

    def month_courses_by_teacher_name
      teacher = Teacher.find_by(name: params[:item])
      teacher.courses.within_month(params[:year].to_i, params[:month].to_i)
    end

    def month_courses_by_language_name
      language = Language.find_by(name: params[:item])
      Course.with_language(language).within_month(params[:year].to_i, params[:month].to_i)
    end
  end
end
