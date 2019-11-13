class CreateStudyFinderTrialSites < ActiveRecord::Migration[4.2]
  def change
    create_table :study_finder_trial_sites do |t|
      t.integer :trial_id
      t.integer :site_id

      t.timestamps null: false
    end
  end
end
