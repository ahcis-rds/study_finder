class CreateStudyFinderSubgroups < ActiveRecord::Migration
  def change
    create_table :study_finder_subgroups do |t|
      t.string :name
      t.integer :group_id

      t.timestamps
    end
  end
end
