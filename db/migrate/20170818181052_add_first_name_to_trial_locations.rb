class AddFirstNameToTrialLocations < ActiveRecord::Migration
  def change
    add_column :study_finder_locations, :first_name, :string
    add_column :study_finder_locations, :backup_first_name, :string
  end
end
