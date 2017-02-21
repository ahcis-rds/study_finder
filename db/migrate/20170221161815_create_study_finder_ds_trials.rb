class CreateStudyFinderDsTrials < ActiveRecord::Migration
  def change
    create_table :study_finder_ds_trials do |t|
      t.integer :disease_site_id
      t.integer :trial_id
    end
  end
end
