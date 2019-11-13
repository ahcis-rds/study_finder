class CreateSystemInfos < ActiveRecord::Migration[4.2]
  def change
    create_table :study_finder_system_infos do |t|
      t.string :initials
      t.string :school_name
      t.string :system_name
      t.string :system_header
      t.string :system_description, limit: 2000
      t.string :search_term
      t.string :default_url
      t.string :default_email
      t.string :research_match_campaign

      t.timestamps
    end
  end
end
