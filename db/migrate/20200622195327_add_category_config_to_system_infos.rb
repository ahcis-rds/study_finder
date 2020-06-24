class AddCategoryConfigToSystemInfos < ActiveRecord::Migration[5.2]
  def change
    add_column :study_finder_system_infos, :display_groups_page, :boolean, null: false, default: true
  end
end
