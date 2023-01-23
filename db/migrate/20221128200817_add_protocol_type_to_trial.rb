class AddProtocolTypeToTrial < ActiveRecord::Migration[5.2]
  def change
    add_column :study_finder_trials, :protocol_type, :string
  end
end
