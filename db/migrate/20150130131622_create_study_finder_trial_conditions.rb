class CreateStudyFinderTrialConditions < ActiveRecord::Migration
  def change
    create_table :study_finder_trial_conditions do |t|
      t.integer :trial_id
      t.integer :condition_id
      t.timestamps
    end
    execute "ALTER TABLE study_finder_trial_conditions ADD INDEX condition_idx (condition_id)"
  end
end
