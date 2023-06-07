FactoryBot.define do
  factory :api_key do
    name { Faker::Adjective.positive }
    token { Faker::Alphanumeric.alphanumeric(number: 10) }
  end
end
