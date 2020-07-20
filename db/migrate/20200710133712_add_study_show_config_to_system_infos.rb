class AddStudyShowConfigToSystemInfos < ActiveRecord::Migration[5.2]
  def change
    add_column :study_finder_system_infos, :display_study_show_page, :boolean, null: false, default: false
  end
end
