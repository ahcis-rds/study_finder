class AddFeaturedToStudyFinderTrials < ActiveRecord::Migration
  def change
    add_column :study_finder_trials, :featured, :integer, default: 0
  end
end
