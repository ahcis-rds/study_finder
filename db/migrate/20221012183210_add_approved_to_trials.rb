class AddApprovedToTrials < ActiveRecord::Migration[5.2]
  def change
    add_column :study_finder_trials, :approved, :boolean, null: false, default: false

    Trial.all.each do |tr|
      tr.update_attributes(approved: true)
    end
  end
end