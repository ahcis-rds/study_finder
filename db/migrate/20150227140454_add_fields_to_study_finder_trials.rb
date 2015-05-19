class AddFieldsToStudyFinderTrials < ActiveRecord::Migration
  def change
    add_column :study_finder_trials, :official_last_name, :string
    add_column :study_finder_trials, :official_first_name, :string
    add_column :study_finder_trials, :official_role, :string
    add_column :study_finder_trials, :official_affiliation, :string
    add_column :study_finder_trials, :contact_last_name, :string
    add_column :study_finder_trials, :contact_first_name, :string
    add_column :study_finder_trials, :contact_phone, :string
    add_column :study_finder_trials, :contact_email, :string
    add_column :study_finder_trials, :contact_backup_last_name, :string
    add_column :study_finder_trials, :contact_backup_first_name, :string
    add_column :study_finder_trials, :contact_backup_phone, :string
    add_column :study_finder_trials, :contact_backup_email, :string
  end
end
