class AddSimpleDescriptionOverride < ActiveRecord::Migration[7.0]
  def change
    add_column :study_finder_trials, :simple_description_override, :string
  end
end
