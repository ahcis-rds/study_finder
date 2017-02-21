class CreateEresearchSites < ActiveRecord::Migration
  def change
    create_table :study_finder_sites do |t|
      t.string :site_name
      t.string :address
      t.string :city
      t.string :state
      t.string :zip

      t.timestamps null: false
    end
  end
end
