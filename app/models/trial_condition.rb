class TrialCondition < ApplicationRecord
  self.table_name = 'study_finder_trial_conditions'
  self.primary_key = :id

  belongs_to :condition
  belongs_to :trial

  has_many :condition_groups, foreign_key: 'condition_id', primary_key: 'condition_id'
end