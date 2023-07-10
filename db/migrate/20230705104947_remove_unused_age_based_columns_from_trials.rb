class RemoveUnusedAgeBasedColumnsFromTrials < ActiveRecord::Migration[7.0]
  def change
    remove_column :study_finder_trials, :maximum_age, :float
    remove_column :study_finder_trials, :max_age_unit, :string
    remove_column :study_finder_trials, :minimum_age, :float
    remove_column :study_finder_trials, :min_age_unit, :string
  end
end
