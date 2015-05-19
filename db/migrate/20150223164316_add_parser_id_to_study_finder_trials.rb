class AddParserIdToStudyFinderTrials < ActiveRecord::Migration
  def change
    add_column :study_finder_trials, :parser_id, :integer
  end
end
