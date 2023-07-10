class AddAgeToStudyFinderTrials < ActiveRecord::Migration[7.0]
  def change
    add_column :study_finder_trials, :age, :string
  end
end
