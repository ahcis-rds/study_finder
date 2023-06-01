class SystemInfo < ApplicationRecord
  self.table_name = 'study_finder_system_infos'

  has_many :trial_attribute_settings
  accepts_nested_attributes_for :trial_attribute_settings, allow_destroy: false, reject_if: :all_blank

  validates_presence_of :secret_key, :default_email, :initials, :school_name

  def self.current
    self.first
  end

  def self.protect_simple_description
    self.first.protect_simple_description
  end
end