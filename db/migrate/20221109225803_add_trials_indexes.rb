class AddTrialsIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :study_finder_trials, :approved
    add_index :study_finder_trials, :recruiting
    add_index :study_finder_trials, :reviewed
    add_index :study_finder_trials, :visible
  end
end
