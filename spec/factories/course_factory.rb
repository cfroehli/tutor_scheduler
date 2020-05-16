FactoryBot.define do
  factory :course do
    time_slot { DateTime.now + rand(1..10).days }
    zoom_url { 'http://course.url' }
  end
end
