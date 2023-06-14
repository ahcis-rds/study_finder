class ChangeDefaultValueForDisplaySimpleDescription < ActiveRecord::Migration[5.2]
  def change 
    change_column_default :study_finder_trials, :display_simple_description, from: false, to: true 
  end

end
