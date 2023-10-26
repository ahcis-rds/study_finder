class SystemInfo < ApplicationRecord
  self.table_name = 'study_finder_system_infos'

  has_many :trial_attribute_settings
  accepts_nested_attributes_for :trial_attribute_settings, allow_destroy: false, reject_if: :all_blank

  validates_presence_of :secret_key, :default_email, :initials, :school_name

  def self.current
    self.first
  end
  
  def self.trial_approval
    self.first.try(:trial_approval)
  end

  def self.alert_on_empty_system_id
    self.first.try(:alert_on_empty_system_id)
  end

  def self.secret_key
    self.first.try(:secret_key)
  end

  def self.trial_attribute_settings
    self.first.try(:trial_attribute_settings)
  end

  def self.display_study_show_page
    self.first.try(:display_study_show_page)
  end

  def self.captcha
    self.first.try(:captcha)
  end

  def self.ga_version
    self.first.try(:google_analytics_version)
  end

end