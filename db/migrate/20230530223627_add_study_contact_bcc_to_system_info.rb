class AddStudyContactBccToSystemInfo < ActiveRecord::Migration[7.0]
  def change
    add_column :study_finder_system_infos, :study_contact_bcc, :string
  end
end
