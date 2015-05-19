class StudyFinder::Subgroup < ActiveRecord::Base
  self.table_name = 'study_finder_subgroups'
  belongs_to :group
end