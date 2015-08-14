class StudyFinder::Group < ActiveRecord::Base
  self.table_name = 'study_finder_groups'

  validates :group_name, presence: true

  has_many :condition_groups
  has_many :conditions, through: :condition_groups
  has_many :subgroups

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
    if conditions_empty?
      count = StudyFinder::Trial.match_all(apply_filters).results.total
    else
      count = StudyFinder::VwGroupTrialCount.where({ id: id }).first.trial_count.to_i
    end

    count
  end
end