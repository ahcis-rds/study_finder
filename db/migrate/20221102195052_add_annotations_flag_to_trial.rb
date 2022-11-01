class AddAnnotationsFlagToTrial < ActiveRecord::Migration[5.2]
  def change
      add_column :study_finder_trials, :annotations_flag, :string
  end
end
