FactoryBot.define do
  factory :trial_condition do
    association :trial
    association :condition
  end
end
