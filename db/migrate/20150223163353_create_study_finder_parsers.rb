class CreateStudyFinderParsers < ActiveRecord::Migration
  def change
    create_table :study_finder_parsers do |t|
      t.string :name
      t.string :klass
      t.timestamps
    end
  end
end
