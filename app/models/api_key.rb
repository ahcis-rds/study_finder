class ApiKey < ApplicationRecord
  validates :name, presence: true

  after_initialize do |api_key|
    api_key.token = SecureRandom.base58(32)
  end
end
