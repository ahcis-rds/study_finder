FactoryBot.define do
  factory :subgroup do
    name { Faker::Adjective.positive}
    association :group
  end
end
