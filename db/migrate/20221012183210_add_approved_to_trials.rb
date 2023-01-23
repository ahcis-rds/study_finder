class AddApprovedToTrials < ActiveRecord::Migration[5.2]
  def change
    add_column :study_finder_trials, :approved, :boolean, null: false, default: false

    Trial.update_all(approved: true)
  end
end