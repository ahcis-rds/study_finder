FactoryBot.define do
  factory :condition_group do
    association :group
    association :condition
  end
end
