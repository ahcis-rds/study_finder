require 'nokogiri'
require 'open-uri'

module Parsers
  class Ctgov 

    @@simple_fields = [
      'brief_title',
      'official_title',
      'acronym',
      'phase',
      'overall_status',
      'verification_date',
      'lastchanged_date',
      'firstreceived_date',
      'brief_summary',
      'detailed_description'
    ]

    # overwriting the built-in initialize method
    def initialize(id, parser_id=nil)
      @id = id
      @url = url
      @parser_id = parser_id
    end

    def url
      "https://clinicaltrials.gov/show/" + @id + "?displayxml=true"
    end

    def load(path=nil)
      path = url if path.nil?
      @contents ||= Hash.from_xml( Nokogiri::XML( open(path) ).xpath('clinical_study').to_s )['clinical_study']
    end

    def contents
      @contents
    end

    def set_contents_from_xml(xml)
      @contents = Hash.from_xml( Nokogiri::XML( xml ).xpath('clinical_study').to_s )['clinical_study']
    end

    def preview
      trial = Trial.new(system_id: @id)

      retrieve_simple_fields(trial)

      trial
    end

    def process()
      trial = Trial.find_or_initialize_by(system_id: @id)
      
      trial.system_id = @id # i think this is just overwriting system_id from the line above

      # Trial does not exist yet, setup defaults
      if trial.id.nil?
        if @contents.has_key?('overall_status') and @contents['overall_status'] == 'Recruiting'
          trial.visible = true # By default recruiting trials are visible unless otherwise specified.
        else
          trial.visible = false
        end

        if @parser_id.nil?
          trial.parser_id = Parser.find_by({ klass: 'Parsers::Ctgov'}).id
        else
          trial.parser_id = @parser_id
        end
      end

      retrieve_simple_fields(trial)

      begin
        trial.added_on = Date.parse(@contents.dig("study_first_posted")) || Date.today
      rescue ArgumentError, TypeError => e
        trial.added_on = Date.today
      end

      if @contents.has_key?('eligibility')
        process_eligibility(trial)
      end
      
      process_contacts(trial)

      if trial.id.nil?
        trial.save
      end

      if @contents.has_key?('conditional_browse') || @contents.has_key?('intervention_browse')
        process_mesh_term(trial)
      end

      trial.updated_at = DateTime.now # Set updated date, even if the trial has not changed.

      # Save associations.
      if @contents.has_key?('condition')
        process_conditions(trial.id)
      end

      if @contents.has_key?('intervention')
        process_interventions(trial.id)
      end

      if @contents.has_key?('location')
        process_locations(trial.id)
      end

      if @contents.has_key?('keyword')
        process_keywords(trial.id)
      end

      trial.save
      
    end

    def process_contacts(trial)

      # Overall official
      if @contents.has_key?('overall_official')
        if @contents['overall_official'].instance_of?(Array)
          overall_offical = @contents['overall_official'][0]
        else
          overall_offical = @contents['overall_official']
        end

        trial.official_last_name = overall_offical['last_name'] if  overall_offical.has_key?('last_name')
        trial.official_role = overall_offical['role'] if  overall_offical.has_key?('role')
        trial.official_affiliation = overall_offical['affiliation'] if  overall_offical.has_key?('affiliation')
      end

      # Primary Contact
      if @contents.has_key?('overall_contact')
        trial.contact_last_name = @contents['overall_contact']['last_name'] if  @contents['overall_contact'].has_key?('last_name')
        trial.contact_phone = @contents['overall_contact']['phone'] if  @contents['overall_contact'].has_key?('phone')
        trial.contact_email = @contents['overall_contact']['email'] if  @contents['overall_contact'].has_key?('email')
      end

      # Backup Contact
      if @contents.has_key?('overall_contact_backup')
        trial.contact_backup_last_name = @contents['overall_contact_backup']['last_name'] if  @contents['overall_contact_backup'].has_key?('last_name')
        trial.contact_backup_phone = @contents['overall_contact_backup']['phone'] if  @contents['overall_contact_backup'].has_key?('phone')
        trial.contact_backup_email = @contents['overall_contact_backup']['email'] if  @contents['overall_contact_backup'].has_key?('email')
      end
    end

    def process_eligibility(trial)
      
      if @contents['eligibility'].has_key?('gender')
        trial.gender = @contents['eligibility']['gender']
      end
      
      if @contents['eligibility'].has_key?('minimum_age')
        trial.minimum_age = @contents['eligibility']['minimum_age'].gsub(' Years', '').gsub(' Year', '') unless @contents['eligibility']['minimum_age'].nil?
        trial.minimum_age = nil if trial.minimum_age == 'N/A'
        trial.min_age_unit = @contents['eligibility']['minimum_age']

        if !trial.min_age_unit.nil? and (trial.min_age_unit.include? 'Month' or trial.min_age_unit.include? 'Months')
          trial.minimum_age = (trial.minimum_age.gsub(' Months', '').gsub(' Month', '').to_f / 12).round(2)
        end

        if !trial.min_age_unit.nil? and (trial.min_age_unit.include? 'Week' or trial.min_age_unit.include? 'Weeks')
          trial.minimum_age = (trial.minimum_age.gsub(' Weeks', '').gsub(' Week', '').to_f * 0.0191781).round(2)
        end

        if !trial.min_age_unit.nil? and (trial.min_age_unit.include? 'Day' or trial.min_age_unit.include? 'Days')
          trial.minimum_age = (trial.minimum_age.gsub(' Days', '').gsub(' Day', '').to_f * 0.002739728571424657).round(2)
        end

      end
      
      if @contents['eligibility'].has_key?('maximum_age')
        trial.maximum_age = @contents['eligibility']['maximum_age'].gsub(' Years', '').gsub(' Year', '') unless @contents['eligibility']['maximum_age'].nil?
        trial.maximum_age = nil if trial.maximum_age == 'N/A'
        trial.max_age_unit = @contents['eligibility']['maximum_age']

        if !trial.max_age_unit.nil? and (trial.max_age_unit.include? 'Month' or trial.max_age_unit.include? 'Months')
          trial.maximum_age = (trial.maximum_age.gsub(' Months', '').gsub(' Month', '').to_f / 12).round(2)
        end

        if !trial.max_age_unit.nil? and (trial.max_age_unit.include? 'Week' or trial.max_age_unit.include? 'Weeks')
          trial.maximum_age = (trial.maximum_age.gsub(' Weeks', '').gsub(' Week', '').to_f * 0.0191781).round(2)
        end

        if !trial.max_age_unit.nil? and (trial.max_age_unit.include? 'Day' or trial.max_age_unit.include? 'Days')
          trial.maximum_age = (trial.maximum_age.gsub(' Days', '').gsub(' Day', '').to_f * 0.002739728571424657).round(2)
        end
        
      end

      if @contents['eligibility'].has_key?('healthy_volunteers')
        if @contents['eligibility']['healthy_volunteers'] == 'Accepts Healthy Volunteers'
          trial.healthy_volunteers_imported = true
        else
          trial.healthy_volunteers_imported = false
        end
      end

      if @contents['eligibility'].has_key?('criteria') && @contents['eligibility']['criteria'].has_key?('textblock')
        trial.eligibility_criteria = @contents['eligibility']['criteria']['textblock']
      end

    end

    def process_mesh_term(trial)
      if (!@contents['conditional_browse'].nil? && @contents['conditional_browse'].has_key?('mesh_term')) || 
         (!@contents['intervention_browse'].nil? && @contents['intervention_browse'].has_key?('mesh_term')) 
        TrialMeshTerm.where(trial_id: trial.id).delete_all
      end
      if !@contents['conditional_browse'].nil? && @contents['conditional_browse'].has_key?('mesh_term')
        process_condition_browse(trial)
      end
      if !@contents['intervention_browse'].nil? && @contents['intervention_browse'].has_key?('mesh_term')
        process_intervention_browse(trial)
      end
    end

    def process_condition_browse(trial)
      mesh_term = @contents['conditional_browse']['mesh_term']
      mesh_term = [mesh_term] unless mesh_term.instance_of?(Array)

      mesh_term.each do |mesh|
        test = TrialMeshTerm.create({
          trial_id: trial.id,
          mesh_term_type: 'Conditional',
          mesh_term: mesh
        })
      end
    end

    def process_intervention_browse(trial)
      mesh_term = @contents['intervention_browse']['mesh_term']
      mesh_term = [mesh_term] unless mesh_term.instance_of?(Array)

      mesh_term.each do |mesh|
        test = TrialMeshTerm.create({
          trial_id: trial.id,
          mesh_term_type: 'Intervention',
          mesh_term: mesh
        })
      end
    end

    def process_conditions(id)
      conditions = @contents['condition']
      conditions = [conditions] unless conditions.instance_of?(Array)
  
      TrialCondition.where(trial_id: id).delete_all

      conditions.each do |c|
        condition = Condition.find_or_initialize_by(condition: c)
        if condition.id.nil?
          condition.save
        end

        TrialCondition.create({
          trial_id: id,
          condition_id: condition.id
        })
      end
    end

    def process_interventions(id)
      interventions = @contents['intervention']
      interventions = [interventions] unless interventions.instance_of?(Array)

      TrialIntervention.where(trial_id: id).delete_all

      interventions.each do |i|
        TrialIntervention.create({
          trial_id: id,
          intervention_type: i['intervention_type'],
          intervention: i['intervention_name'],
          description: i['description']
        })
      end
    end

    def process_locations(id)
      locations = @contents['location']
      locations = [locations] unless locations.instance_of?(Array)

      TrialLocation.where(trial_id: id).delete_all

      locations.each do |l|
        facility = l['facility'] if l.has_key?('facility')
        location = Location.find_or_initialize_by(location: facility['name'])
        
        if facility.has_key?('address')
          address = facility['address']
          location.city = address['city'] if address.has_key?('city')
          location.state = address['state'] if address.has_key?('state')
          location.zip = address['zip'] if address.has_key?('zip')
          location.country = address['country'] if address.has_key?('country')
        end

        location.save

        trial_location_hash = {
          trial_id: id,
          location_id: location.id
        }

        if l.has_key?('status')
          trial_location_hash['status'] = l['status']
        end

        if l.has_key?('contact')
          contact = l['contact']
          trial_location_hash['last_name'] = contact['last_name'] if contact.has_key?('last_name')
          trial_location_hash['phone'] = contact['phone'] if contact.has_key?('phone')
          trial_location_hash['email'] = contact['email'] if contact.has_key?('email')
        end

        if l.has_key?('contact_backup')
          contact_backup = l['contact_backup']
          trial_location_hash['backup_last_name'] = contact_backup['last_name'] if contact_backup.has_key?('last_name')
          trial_location_hash['backup_phone'] = contact_backup['phone'] if contact_backup.has_key?('phone')
          trial_location_hash['backup_email'] = contact_backup['email'] if contact_backup.has_key?('email')
        end

        if l.has_key?('status')
          trial_location_hash['status'] = l['status']
        end

        TrialLocation.create(trial_location_hash)
      end
    end

    def process_keywords(id)
      
      keywords = @contents['keyword']
      keywords = [keywords] unless keywords.instance_of?(Array)

      TrialKeyword.where(trial_id: id).delete_all

      keywords.each do |k|
        TrialKeyword.create({
          trial_id: id,
          keyword: k
        })
      end

    end

    def retrieve_simple_fields(trial)
      previous_status = trial.overall_status
      
      # Look at simple fields and update where appropriate.
      @@simple_fields.each do |f|
        if @contents.has_key?(f)
          if f == 'brief_summary' || f == 'detailed_description'
            trial[f] = @contents[f]['textblock']
          else
            trial[f] = @contents[f]
          end
          
          if f == 'overall_status'
            trial.recruiting = @contents[f] == 'Recruiting'
            trial.visible = trial.recruiting
          end
        end
      end
    end

  end
end
