class CreateStudyFinderTrialKeywords < ActiveRecord::Migration
  def change
    create_table :study_finder_trial_keywords do |t|
      t.integer :trial_id
      t.string :keyword

      t.timestamps
    end
  end
end
