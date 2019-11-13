class CreateStudyFinderTrialLocations < ActiveRecord::Migration[4.2]
  def change
    create_table :study_finder_trial_locations do |t|
      t.integer :trial_id
      t.integer :location_id
      t.string :status
      t.string :last_name
      t.string :phone
      t.string :email
      t.string :backup_last_name
      t.string :backup_phone
      t.string :backup_email
      t.string :investigator_last_name
      t.string :investigator_role

      t.timestamps
    end
  end
end
