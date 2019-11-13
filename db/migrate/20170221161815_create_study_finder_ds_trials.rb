class CreateStudyFinderDsTrials < ActiveRecord::Migration[4.2]
  def change
    create_table :study_finder_ds_trials do |t|
      t.integer :disease_site_id
      t.integer :trial_id
    end
  end
end
