class AddMinMaxUnits < ActiveRecord::Migration
  def change
    add_column :study_finder_trials, :min_age_unit, :string
    add_column :study_finder_trials, :max_age_unit, :string
  end
end
