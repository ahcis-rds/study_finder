class AddCancerYnToStudyFinderTrials < ActiveRecord::Migration
  def change
    add_column :study_finder_trials, :cancer_yn, :string
  end
end
