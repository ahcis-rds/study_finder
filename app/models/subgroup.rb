class Subgroup < ApplicationRecord
  self.table_name = 'study_finder_subgroups'
  belongs_to :group, optional: true

  validates_presence_of :name
end