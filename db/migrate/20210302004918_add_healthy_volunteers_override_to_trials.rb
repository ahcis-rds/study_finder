class AddHealthyVolunteersOverrideToTrials < ActiveRecord::Migration[5.2]
  def change
    add_column :study_finder_trials, :healthy_volunteers_imported, :boolean, default: nil
    add_column :study_finder_trials, :healthy_volunteers_override, :boolean, default: nil
  end
end
