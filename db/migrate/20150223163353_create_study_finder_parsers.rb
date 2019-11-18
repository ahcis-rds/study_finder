class CreateStudyFinderParsers < ActiveRecord::Migration[4.2]
  def change
    create_table :study_finder_parsers do |t|
      t.string :name
      t.string :klass
      t.timestamps
    end
  end
end
