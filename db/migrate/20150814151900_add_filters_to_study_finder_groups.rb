class AddFiltersToStudyFinderGroups < ActiveRecord::Migration
  def change
    add_column :study_finder_groups, :children, :boolean
    add_column :study_finder_groups, :adults, :boolean
    add_column :study_finder_groups, :healthy_volunteers, :boolean
  end
end
