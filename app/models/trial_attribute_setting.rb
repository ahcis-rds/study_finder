class TrialAttributeSetting < ApplicationRecord
  belongs_to :system_infos, class_name: 'SystemInfo'
  validates :attribute_name, presence: true
end