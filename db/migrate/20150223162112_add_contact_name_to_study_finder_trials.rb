class AddContactNameToStudyFinderTrials < ActiveRecord::Migration[4.2]
  def change
    add_column :study_finder_trials, :contact_override_first_name, :string
    add_column :study_finder_trials, :contact_override_last_name, :string
  end
end
