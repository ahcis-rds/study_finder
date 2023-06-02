class AddProtectSimpleDescriptionToSystemInfos < ActiveRecord::Migration[7.0]
  def change
    add_column :study_finder_system_infos, :protect_simple_description, :boolean, null: false, default: false
  end
end
