FactoryBot.define do
  factory :group do
    group_name { Faker::Ancient.hero}
    children { false }
    adults { true }
    healthy_volunteers { false }
  end
end
