class AddRecruitmentUrlToStudyFinderTrials < ActiveRecord::Migration
  def change
    add_column :study_finder_trials, :recruitment_url, :string
  end
end
