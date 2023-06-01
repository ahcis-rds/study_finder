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
  
  def self.trial_approval
    self.first.trial_approval
  end

  def self.alert_on_empty_system_id
    self.first.alert_on_empty_system_id
  end

  def self.secret_key
    self.first.secret_key
  end

end