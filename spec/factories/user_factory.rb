FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    email { "#{username}@server.com" }
    password { 'password' }

    factory :admin do
      after(:create) { |u| u.add_role(:admin) }
    end
  end
end
