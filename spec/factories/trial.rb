FactoryBot.define do
  sequence(:system_id, 10000) { |n| "STUDY#{n}" }
  factory :trial do
    system_id { generate(:system_id) }
    brief_title { Faker::Lorem.sentence }
    approved { true }
    visible { true }
  end
end
