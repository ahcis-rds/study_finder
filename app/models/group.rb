class Group < ApplicationRecord
  self.table_name = 'study_finder_groups'

  validates :group_name, presence: true

  has_many :condition_groups
  has_many :conditions, through: :condition_groups
  has_many :trial_conditions, through: :condition_groups
  has_many :trials, through: :trial_conditions
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
    if SystemInfo.trial_approval
      trials.where(visible: true, approved: true).distinct.count(:id)
    else
      trials.where(visible: true).distinct.count(:id)
    end
  end
end