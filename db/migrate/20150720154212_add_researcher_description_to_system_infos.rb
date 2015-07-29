class AddResearcherDescriptionToSystemInfos < ActiveRecord::Migration
  def change
    add_column :study_finder_system_infos, :researcher_description, :text
  end
end
