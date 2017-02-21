class StudyFinder::DsTrial < ActiveRecord::Base
  self.table_name = 'study_finder_ds_trials'

  belongs_to :trial
  belongs_to :disease_site
end