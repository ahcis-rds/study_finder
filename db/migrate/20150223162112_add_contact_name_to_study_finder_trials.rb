class AddContactNameToStudyFinderTrials < ActiveRecord::Migration
  def change
    add_column :study_finder_trials, :contact_override_first_name, :string
    add_column :study_finder_trials, :contact_override_last_name, :string
  end
end
