class AddHealthyVolunteersToStudyFinderSystemsInfos < ActiveRecord::Migration[7.0]
  def change
    add_column :study_finder_system_infos, :healthy_volunteers_filter, :boolean, null: false, default: true
  end
end
