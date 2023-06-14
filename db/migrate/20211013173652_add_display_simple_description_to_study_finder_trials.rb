class AddDisplaySimpleDescriptionToStudyFinderTrials < ActiveRecord::Migration[5.2]
  def change
    add_column :study_finder_trials, :display_simple_description, :boolean, null: false, default: false
  end
end
