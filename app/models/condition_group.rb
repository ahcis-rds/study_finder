class ConditionGroup < ApplicationRecord
  self.table_name = 'study_finder_condition_groups'

  belongs_to :condition, counter_cache: true
  belongs_to :group
  belongs_to :trial_condition, foreign_key: :condition_id, primary_key: :condition_id, optional: true
end
