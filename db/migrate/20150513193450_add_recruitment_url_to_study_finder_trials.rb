class AddRecruitmentUrlToStudyFinderTrials < ActiveRecord::Migration[4.2]
  def change
    add_column :study_finder_trials, :recruitment_url, :string
  end
end
