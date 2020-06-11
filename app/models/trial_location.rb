class TrialLocation < ApplicationRecord
  self.table_name = 'study_finder_trial_locations'

  belongs_to :location

  def location_name
    location.location unless location.nil?
  end
  
  def city
    location.city unless location.nil?
  end

  def state
    location.state unless location.nil?
  end

  def zip
    location.zip unless location.nil?
  end

  def country
    location.country unless location.nil?
  end

end