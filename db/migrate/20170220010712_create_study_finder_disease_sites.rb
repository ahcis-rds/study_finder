class CreateStudyFinderDiseaseSites < ActiveRecord::Migration
  def change
    create_table :study_finder_disease_sites do |t|
      t.string :disease_site_name
      t.integer :group_id

      t.timestamps null: false
    end
  end
end
