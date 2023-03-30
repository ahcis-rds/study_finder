class AddIndexesToTrialLocations < ActiveRecord::Migration[7.0]
  def change
    add_index :study_finder_trial_locations, :trial_id
    add_index :study_finder_trial_locations, :location_id
  end
end
