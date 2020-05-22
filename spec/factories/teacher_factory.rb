FactoryBot.define do
  factory :teacher do
    user
    sequence(:name) { |n| "teacher#{n}" }

    factory :teacher_with_courses do
      transient do
        courses_count { 5 }
      end

      after(:create) do |teacher, evaluator|
        create_list(:course, evaluator.courses_count, teacher: teacher)
      end
    end
  end
end
