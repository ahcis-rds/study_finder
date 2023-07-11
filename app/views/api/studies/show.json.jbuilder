if @trial.blank?
	json.nil!
else
	json.id @trial.id
	json.system_id @trial.system_id
	json.brief_title @trial.brief_title
	json.official_title @trial.official_title
	json.contact_last_name @trial.contact_last_name
	json.contact_first_name @trial.contact_first_name
	json.contact_email @trial.contact_email
	json.contact_override @trial.contact_override
	json.contact_override_first_name @trial.contact_override_first_name
	json.contact_override_last_name @trial.contact_override_last_name
	json.irb_number @trial.irb_number
	json.overall_status @trial.overall_status
	json.phase @trial.phase
	json.pi_id @trial.pi_id
	json.pi_name @trial.pi_name
	json.recruiting @trial.recruiting
	json.simple_description @trial.simple_description
	json.display_simple_description @trial.display_simple_description
	json.visible @trial.visible
	json.eligibility_criteria @trial.eligibility_criteria
	json.age @trial.age
	json.healthy_volunteers_imported @trial.healthy_volunteers_imported
	json.gender @trial.gender
	json.detailed_description @trial.detailed_description
	json.protocol_type @trial.protocol_type
	json.nct_id @trial.nct_id
	json.official_title @trial.official_title
	json.brief_summary @trial.brief_summary
	json.keywords @trial.keyword_values
	json.conditions @trial.condition_values
	json.locations @trial.locations
	json.interventions @trial.trial_interventions
end
