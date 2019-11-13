class AddIrbNumberToStudyFinderTrials < ActiveRecord::Migration[4.2]
  def change
    add_column :study_finder_trials, :irb_number, :string
  end
end
