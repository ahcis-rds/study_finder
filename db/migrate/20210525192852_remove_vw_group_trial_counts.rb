class RemoveVwGroupTrialCounts < ActiveRecord::Migration[5.2]
  def change
  	execute "DROP VIEW vw_study_finder_trial_counts"
    execute "DROP VIEW vw_study_finder_trial_gp_name"
  end
end
