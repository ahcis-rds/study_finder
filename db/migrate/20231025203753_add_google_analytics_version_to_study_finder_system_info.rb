class AddGoogleAnalyticsVersionToStudyFinderSystemInfo < ActiveRecord::Migration[7.0]
  def change
    add_column :study_finder_system_infos, :google_analytics_version, :integer
  end
end
