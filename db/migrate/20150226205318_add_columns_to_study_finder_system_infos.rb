class AddColumnsToStudyFinderSystemInfos < ActiveRecord::Migration[4.2]
  def change
    add_column :study_finder_system_infos, :google_analytics_id, :string
    add_column :study_finder_system_infos, :display_all_locations, :boolean
    add_column :study_finder_system_infos, :contact_email_suffix, :string
  end
end
