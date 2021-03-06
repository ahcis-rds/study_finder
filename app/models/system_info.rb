class SystemInfo < ApplicationRecord
  self.table_name = 'study_finder_system_infos'

  has_many :trial_attribute_settings#, optional: true
  accepts_nested_attributes_for :trial_attribute_settings, allow_destroy: false, reject_if: :all_blank

  validates_presence_of :secret_key, :default_email, :initials, :school_name
  # validates_format_of :secret_key, with: /[^0-9a-z]/i

  def self.current
    self.first
  end
end