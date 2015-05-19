class CreateStudyFinderLocations < ActiveRecord::Migration
  def change
    create_table :study_finder_locations do |t|
      t.string :location, limit: 1000
      t.string :city
      t.string :state
      t.string :zip
      t.string :country

      t.timestamps
    end
  end
end
