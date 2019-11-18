class CreateTrials < ActiveRecord::Migration[4.2]
  def change
    create_table :study_finder_trials do |t|
      
      # Standard Trial Fields
      t.string :system_id
      t.string :brief_title, limit: 1000
      t.string :official_title, limit: 4000
      t.string :acronym
      t.string :phase

      t.string :overall_status

      t.string :source, limit: 1000
      t.string :verification_date
      t.text :brief_summary
      t.text :detailed_description

      t.string :gender
      t.string :minimum_age
      t.string :maximum_age

      t.boolean :healthy_volunteers

      # StudyFinder Added Fields
      t.string :simple_description, limit: 4000
      t.string :contact_override
      t.boolean :visible
      t.boolean :recruiting

      t.timestamps
    end
  end
end
