class AddNctIdToStudyFinderTrials < ActiveRecord::Migration[5.2]
  def up
    add_column :study_finder_trials, :nct_id, :string
    execute "update study_finder_trials set nct_id = system_id"
  end
  def down 
    remove_column :study_finder_trials, :nct_id, :string
  end
end
