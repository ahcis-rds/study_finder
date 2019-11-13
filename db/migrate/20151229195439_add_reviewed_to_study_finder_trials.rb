class AddReviewedToStudyFinderTrials < ActiveRecord::Migration[4.2]
  def change
    add_column :study_finder_trials, :reviewed, :boolean
  end
end
