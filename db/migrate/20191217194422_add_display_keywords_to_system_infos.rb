class AddDisplayKeywordsToSystemInfos < ActiveRecord::Migration[5.2]
  def change
    add_column :study_finder_system_infos, :display_keywords, :boolean, default: true
  end
end
