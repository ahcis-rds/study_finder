class StudyFinder::Group < ActiveRecord::Base
  self.table_name = 'study_finder_groups'

  has_many :condition_groups
  has_many :conditions, through: :condition_groups
  has_many :subgroups
end