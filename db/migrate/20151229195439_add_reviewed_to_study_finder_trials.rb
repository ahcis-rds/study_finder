class AddReviewedToStudyFinderTrials < ActiveRecord::Migration
  def change
    add_column :study_finder_trials, :reviewed, :boolean
  end
end
