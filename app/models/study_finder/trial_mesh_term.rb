class StudyFinder::TrialMeshTerm < ApplicationRecord
  self.table_name = 'study_finder_trial_mesh_terms'

  belongs_to :trial
end
