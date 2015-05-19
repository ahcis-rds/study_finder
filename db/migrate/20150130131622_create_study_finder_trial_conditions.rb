class CreateStudyFinderTrialConditions < ActiveRecord::Migration
  def change
    create_table :study_finder_trial_conditions do |t|
      t.integer :trial_id
      t.integer :condition_id
      t.timestamps
    end
  end
end
