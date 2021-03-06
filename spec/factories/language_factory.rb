FactoryBot.define do
  factory :language do
    trait :english do
      code { 'en' }
      name { 'English' }
    end

    trait :spanish do
      code { 'es' }
      name { 'Spanish' }
    end

    trait :french do
      code { 'fr' }
      name { 'French' }
    end

    trait :italian do
      code { 'it' }
      name { 'Italian' }
    end
  end
end
