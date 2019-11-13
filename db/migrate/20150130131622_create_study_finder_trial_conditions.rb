class CreateStudyFinderTrialConditions < ActiveRecord::Migration[4.2]
  def change
    create_table :study_finder_trial_conditions do |t|
      t.integer :trial_id
      t.integer :condition_id
      t.timestamps
    end
    execute "CREATE INDEX condition_idx ON study_finder_trial_conditions (condition_id)"
  end
end
