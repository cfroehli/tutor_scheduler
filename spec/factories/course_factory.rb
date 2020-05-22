FactoryBot.define do
  factory :course do
    time_slot do
      existing_slots = Course.all.pluck(:time_slot).to_a
      d = (DateTime.current + rand(1..10).days).change(hour: rand(7..22), minute: 0, sec: 0, usec: 0) while d.nil? || existing_slots.include?(d)
      d
    end
    zoom_url { 'http://course.url' }
  end
end
