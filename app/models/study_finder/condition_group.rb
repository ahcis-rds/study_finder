class StudyFinder::ConditionGroup < ActiveRecord::Base
  self.table_name = 'study_finder_condition_groups'

  belongs_to :condition
  belongs_to :group
  belongs_to :trial_condition, foreign_key: :condition_id
end
