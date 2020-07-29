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
    system = SystemInfo.first
    TrialAttributeSetting.create(system_info_id: system.id, attribute_name: 'Overall Status', attribute_key: 'overall_status', attribute_label: 'Status:', display_attribute_on_list: false)
    TrialAttributeSetting.create(system_info_id: system.id, attribute_name: 'Simple Description', attribute_key: 'simple_description', attribute_label: 'Description:', display_attribute_if_null_on_list: false, display_attribute_if_null_on_show: false)
    TrialAttributeSetting.create(system_info_id: system.id, attribute_name: 'Contacts', attribute_key: 'contacts', attribute_label: 'Contact(s):')
    TrialAttributeSetting.create(system_info_id: system.id, attribute_name: 'Principal Investigator', attribute_key: 'principal_investigator:', attribute_label: 'Principal Investigator')
    TrialAttributeSetting.create(system_info_id: system.id, attribute_name: 'Principal Investigator ID', attribute_key: 'principal_investigator_id:', attribute_label: 'Principal Investigator ID')
    TrialAttributeSetting.create(system_info_id: system.id, attribute_name: 'Gender', attribute_key: 'gender', attribute_label: 'Sex:')
    TrialAttributeSetting.create(system_info_id: system.id, attribute_name: 'Age', attribute_key: 'age', attribute_label: 'Age:')
    TrialAttributeSetting.create(system_info_id: system.id, attribute_name: 'Phase', attribute_key: 'phase', attribute_label: 'Phase:')
    TrialAttributeSetting.create(system_info_id: system.id, attribute_name: 'IRB Number', attribute_key: 'irb_number', attribute_label: 'IRB Number:', display_attribute_if_null_on_list: false)
    TrialAttributeSetting.create(system_info_id: system.id, attribute_name: 'Healthy Volunteers', attribute_key: 'healthy_volunteers', attribute_label: 'Healthy Volunteers:')
    TrialAttributeSetting.create(system_info_id: system.id, attribute_name: 'System ID', attribute_key: 'system_id', attribute_label: 'System ID:')
    TrialAttributeSetting.create(system_info_id: system.id, attribute_name: 'Eligibility Criteria', attribute_key: 'eligibility_criteria', attribute_label: 'Eligibility Criteria:', display_label_on_show: false, display_label_on_list: false, display_attribute_if_null_on_list: false)
    TrialAttributeSetting.create(system_info_id: system.id, attribute_name: 'Interventions', attribute_key: 'interventions', attribute_label: 'Interventions:', display_attribute_if_null_on_list: false, display_attribute_if_null_on_show: false)
    TrialAttributeSetting.create(system_info_id: system.id, attribute_name: 'Conditions', attribute_key: 'conditions', attribute_label: 'Conditions:', display_attribute_if_null_on_list: false, display_attribute_if_null_on_show: false)
    TrialAttributeSetting.create(system_info_id: system.id, attribute_name: 'Keywords', attribute_key: 'keywords', attribute_label: 'Keywords:', display_attribute_if_null_on_list: false, display_attribute_if_null_on_show: false)
    TrialAttributeSetting.create(system_info_id: system.id, attribute_name: 'Sites', attribute_key: 'sites', attribute_label: 'Sites:', display_attribute_on_show: false, display_attribute_if_null_on_list: false, display_attribute_if_null_on_list: false)
    TrialAttributeSetting.create(system_info_id: system.id, attribute_name: 'Disease Sites', attribute_key: 'disease_sites', attribute_label: 'Disease Sites:', display_attribute_on_show: false, display_attribute_if_null_on_list: false, display_attribute_if_null_on_list: false)
  end
end
