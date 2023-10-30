class Subgroup < ApplicationRecord
  self.table_name = 'study_finder_subgroups'

  belongs_to :group, optional: true
  has_many :trial_subgroups
  has_many :trials, through: :trial_subgroups

  validates_presence_of :name

  def self.distinct_values
    self.distinct(:name).order(:name).pluck(:name)
  end
end
