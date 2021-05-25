class RemoveVwStudyFinderTrialGroups < ActiveRecord::Migration[5.2]
  def change
    execute "drop view vw_study_finder_trial_groups"
  end
end
