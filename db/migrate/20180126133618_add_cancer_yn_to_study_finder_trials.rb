class AddCancerYnToStudyFinderTrials < ActiveRecord::Migration[4.2]
  def change
    add_column :study_finder_trials, :cancer_yn, :string
  end
end
