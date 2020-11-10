class AddContactUrlToTrials < ActiveRecord::Migration[5.2]
  def change
  	add_column :study_finder_trials, :contact_url, :string
  	add_column :study_finder_trials, :contact_url_override, :string
  end
end
