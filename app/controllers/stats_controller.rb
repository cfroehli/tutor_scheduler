class StatsController < ApplicationController
  def courses_heatmap
    courses = Course.group('extract(isodow from time_slot)::integer',
                           'extract(hour from time_slot)::integer')
    course_slots = courses.count
    signed_up = courses.signed_up.count
    stats = []
    (0..6).each do |day|
      day_stats = [ 'SMTWTFS'[day] ]
      (7..22).each do |hour|
        key = [day, hour]
        slots = course_slots[key]
        if slots.nil?
          day_stats << {text: "NA", ratio: 0}
        else
          signed_up_count = signed_up[key] || 0
          day_stats << { text: "#{signed_up_count} / #{slots}" ,
                         ratio: signed_up_count.to_d / slots }
        end
      end
      stats << day_stats
    end
    @stats = stats
  end
end
