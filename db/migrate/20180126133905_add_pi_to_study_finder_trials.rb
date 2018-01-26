class AddPiToStudyFinderTrials < ActiveRecord::Migration
  def change
    add_column :study_finder_trials, :pi_name, :string
    add_column :study_finder_trials, :pi_id, :string
  end
end
