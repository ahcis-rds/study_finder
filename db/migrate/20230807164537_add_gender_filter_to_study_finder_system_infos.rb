class AddGenderFilterToStudyFinderSystemInfos < ActiveRecord::Migration[7.0]
  def change
    add_column :study_finder_system_infos, :gender_filter, :boolean, null: false, default: true
  end
end
