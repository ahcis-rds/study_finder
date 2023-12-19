FactoryBot.define do
  factory :parser do
    name { 'clinicaltrials.gov' }
    klass { 'Parsers::Ctgov' }
  end
end
