class AddParserIdToStudyFinderTrials < ActiveRecord::Migration[4.2]
  def change
    add_column :study_finder_trials, :parser_id, :integer
  end
end
