class Group < ApplicationRecord
  self.table_name = 'study_finder_groups'

  validates :group_name, presence: true

  has_many :condition_groups
  has_many :conditions, through: :condition_groups
  has_many :subgroups

  accepts_nested_attributes_for :subgroups, allow_destroy: true, reject_if: :all_blank

  def apply_filters
    filters = {}
    filters['children'] = 1 if children
    filters['adults'] = 1 if adults
    filters['healthy_volunteers'] = 1 if healthy_volunteers

    return filters
  end

  def conditions_empty?
    condition_groups.empty?
  end

  def study_count
    VwGroupTrialCount.find(id).trial_count
  end
end