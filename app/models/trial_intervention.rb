class TrialIntervention < ApplicationRecord
  self.table_name = 'study_finder_trial_intervents'
  belongs_to :trial

  def to_s
    if !intervention_type.blank? && !intervention.blank?
      "#{intervention_type}: #{intervention}"
    elsif !intervention_type.blank?
      intervention_type
    elsif !intervention.blank?
      intervention
    end
  end

  def as_json(options = {})
    {
      intervention_type: self.intervention_type,
      intervention: self.intervention
    }
  end
end
