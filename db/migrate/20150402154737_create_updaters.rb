class CreateUpdaters < ActiveRecord::Migration[4.2]
  def change
    create_table :study_finder_updaters do |t|
      t.integer :parser_id
      t.integer :num_updated

      t.timestamps
    end
  end
end
