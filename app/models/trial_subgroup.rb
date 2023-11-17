class TrialSubgroup < ApplicationRecord
  self.table_name = 'study_finder_trial_subgroups'

  belongs_to :subgroup
  belongs_to :trial
end
