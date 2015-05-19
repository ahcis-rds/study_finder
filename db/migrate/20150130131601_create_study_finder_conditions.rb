class CreateStudyFinderConditions < ActiveRecord::Migration
  def change
    create_table :study_finder_conditions do |t|
      t.string :condition, limit: 1000
      
      t.timestamps
    end
  end
end
