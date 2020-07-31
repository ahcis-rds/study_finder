class CreateTrialAttributeSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :trial_attribute_settings do |t|
      t.integer :system_info_id
      t.string :attribute_name
      t.string :attribute_key
      t.string :attribute_label
      t.boolean :display_label_on_list, default: true
      t.boolean :display_attribute_on_list, default: true
      t.boolean :display_attribute_if_null_on_list, default: true
      t.boolean :display_label_on_show, default: true
      t.boolean :display_attribute_on_show, default: true
      t.boolean :display_attribute_if_null_on_show, default: true
    end

    #seed data
    up_only do
      system_info = SystemInfo.first
      if system_info
        attributes = JSON.parse(IO.read(Rails.root.join("db/seeds/trial_attribute_settings.json")))
        system_info.trial_attribute_settings.create(attributes)
      end
    end
  end
end
