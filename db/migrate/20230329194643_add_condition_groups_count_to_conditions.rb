class AddConditionGroupsCountToConditions < ActiveRecord::Migration[7.0]
  def change
    add_column :study_finder_conditions, :condition_groups_count, :integer
  end
end
