class AddFeaturedToStudyFinderTrials < ActiveRecord::Migration[4.2]
  def change
    add_column :study_finder_trials, :featured, :integer, default: 0
  end
end
