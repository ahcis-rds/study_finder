FactoryBot.define do
  sequence(:system_id, 10000) { |n| "STUDY#{n}" }
  factory :trial do
    system_id { generate(:system_id) }
  end
end
