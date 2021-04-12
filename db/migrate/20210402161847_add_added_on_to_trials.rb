class AddAddedOnToTrials < ActiveRecord::Migration[5.2]
  def change
    add_column :study_finder_trials, :added_on, :date
  end
end
