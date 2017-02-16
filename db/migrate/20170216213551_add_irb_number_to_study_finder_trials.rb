class AddIrbNumberToStudyFinderTrials < ActiveRecord::Migration
  def change
    add_column :study_finder_trials, :irb_number, :string
  end
end
