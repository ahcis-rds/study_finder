FactoryBot.define do
  sequence(:system_id, 10000) { |n| "STUDY#{n}" }
  sequence(:nct_id, 10000) { |n| "NCT#{n}" }
  factory :trial do
    system_id { generate(:system_id) }
    nct_id { generate(:nct_id) }
    brief_title { Faker::Lorem.sentence }
    approved { true }
    visible { true }
  end
end
