class StudyFinder::DsTrial < ApplicationRecord
  self.table_name = 'study_finder_ds_trials'

  belongs_to :trial
  belongs_to :disease_site
end