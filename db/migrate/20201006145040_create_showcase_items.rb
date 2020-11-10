class CreateShowcaseItems < ActiveRecord::Migration[5.2]
  def change
    create_table :showcase_items do |t|
    	t.string :name
    	t.string :title
    	t.text :caption
    	t.string :url
    	t.boolean :active, default: false
        t.integer :sort_order

    	t.timestamps
    end

    add_column :study_finder_system_infos, :enable_showcase, :boolean, null: false, default: false
    add_column :study_finder_system_infos, :show_showcase_indicators, :boolean, null: false, default: true
    add_column :study_finder_system_infos, :show_showcase_controls, :boolean, null: false, default: false
  end
end
 