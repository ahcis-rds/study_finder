class AddReviewedToStudyFinderTrials < ActiveRecord::Migration
  def change
    add_column :study_finder_trials, :reviewed, :boolean, default: false
  end
end
