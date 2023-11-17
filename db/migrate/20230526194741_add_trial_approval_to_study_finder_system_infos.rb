class AddTrialApprovalToStudyFinderSystemInfos < ActiveRecord::Migration[7.0]
  def change
    add_column :study_finder_system_infos, :trial_approval, :boolean, null: false, default: false
  end
end
