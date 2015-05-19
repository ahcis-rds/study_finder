class StudyFinder::BaseTrial < ActiveRecord::Base
  self.table_name = 'study_finder_trials'

  belongs_to :parser
  has_many :trial_interventions, foreign_key: :trial_id
  
  has_many :trial_conditions, foreign_key: :trial_id
  has_many :conditions, through: :trial_conditions
  
  has_many :trial_locations
  has_many :locations, -> { order 'study_finder_locations.location' }, through: :trial_locations

  def display_title
    display = brief_title
    unless acronym.nil?
      display += ' (' + acronym + ')'
    end
    display
  end

  def self.active_trials
    where({ visible: true })
  end

  def min_age
    if minimum_age.nil?
      age = 0
    else
      age = minimum_age.to_f
    end

    age
  end

  def max_age
    if maximum_age.nil?
      age = 1000
    else
      age = maximum_age.to_f
    end

    age
  end

  def interventions
    trial_interventions.map { |t| "#{t.intervention_type}: #{t.intervention}" }.join('; ') if trial_interventions.any?
  end

  def conditions_map
    conditions.map { |t| "#{t.condition}" }.join('; ') if conditions.any?
  end

  def category_ids
    StudyFinder::VwStudyFinderTrialGroups.where({ trial_id: id }).map(&:group_id)
  end
end