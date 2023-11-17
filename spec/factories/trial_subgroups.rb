FactoryBot.define do
  factory :trial_subgroup do
    association :subgroup
    association :trial
  end
end
