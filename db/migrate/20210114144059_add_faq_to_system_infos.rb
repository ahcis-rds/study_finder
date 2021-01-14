class AddFaqToSystemInfos < ActiveRecord::Migration[5.2]
  def change
  	 add_column :study_finder_system_infos, :faq_description, :text
  end
end
