class TrialAttributeSetting < ApplicationRecord
  belongs_to :system_info
  validates :attribute_name, presence: true
end