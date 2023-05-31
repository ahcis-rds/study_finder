class AddAlertOnEmptySystemIdToSystemInfo < ActiveRecord::Migration[7.0]
  def change
    add_column :study_finder_system_infos, :alert_on_empty_system_id, :boolean, null: false, default: false
  end
end
