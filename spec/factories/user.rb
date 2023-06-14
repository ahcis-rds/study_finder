FactoryBot.define do
  sequence(:internet_id, 1000) { |n| "user#{n}" }
  factory :user do
    internet_id { generate(:internet_id) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
  end
end
