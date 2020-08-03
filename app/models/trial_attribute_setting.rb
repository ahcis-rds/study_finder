class TrialAttributeSetting < ApplicationRecord
  belongs_to :system_infos
  validates :attribute_name, presence: true
end