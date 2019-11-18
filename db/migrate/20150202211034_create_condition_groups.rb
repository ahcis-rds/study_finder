class CreateConditionGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :study_finder_condition_groups do |t|
      t.integer :group_id
      t.integer :condition_id

      t.timestamps
    end
  end
end
