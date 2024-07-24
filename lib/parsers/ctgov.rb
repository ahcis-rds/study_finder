require 'nokogiri'
require 'open-uri'

module Parsers
  class Ctgov 

    @@simple_fields = {
      brief_title: ['protocolSection', 'identificationModule', 'briefTitle'],
      official_title: ['protocolSection', 'identificationModule', 'officialTitle'],
      acronym: ['protocolSection', 'identificationModule', 'acronym'],
      phase: ['protocolSection', 'designModule', 'phases', 0],
      verification_date: ['protocolSection', 'statusModule', 'statusVerifiedDate'],
      lastchanged_date: ['protocolSection', 'statusModule', 'lastUpdateSubmitDate'],
      firstreceived_date: ['protocolSection', 'statusModule', 'studyFirstSubmitDate'],
      brief_summary: ['protocolSection', 'descriptionModule', 'briefSummary'],
      detailed_description: ['protocolSection', 'descriptionModule', 'detailedDescription']
    }

    # overwriting the built-in initialize method
    def initialize(id, parser_id=nil, data)
      @id = id
      @parser_id = parser_id
      @data = data
    end

    def contents
      @data
    end

    def location_search_term
      @location_search_term ||= SystemInfo.first.search_term
    end

    def locations
      @data.dig('protocolSection', 'contactsLocationsModule', 'locations')
    end

    def location
      locations.filter do |location|
        /#{Regexp.escape(location_search_term)}/i.match?(location.dig("facility"))
      end.first || {}
    end

    def location_status
      location.dig("status")
    end

    def overall_status
      @data.dig('protocolSection', 'statusModule', 'overallStatus')
    end

    def calculated_status
      location_status || overall_status
    end

    def preview
      trial = Trial.new(system_id: @id)

      retrieve_simple_fields(trial)

      trial
    end

    def process
      trial = Trial.find_or_initialize_by(system_id: @id)
      
      trial.system_id = @id # i think this is just overwriting system_id from the line above

      # Trial does not exist yet, setup defaults
      if trial.id.nil?
        if !overall_status.blank? and overall_status.downcase == 'recruiting'
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
        trial.added_on = Date.parse(@data.dig('protocolSection', 'statusModule', 'studyFirstSubmitDate')) || Date.today
      rescue ArgumentError, TypeError => e
        trial.added_on = Date.today
      end

      if @data.dig('protocolSection', 'eligibilityModule')
        process_eligibility(trial)
      end
      
      process_contacts(trial)

      if trial.id.nil?
        trial.save
      end

      if @data.dig('derivedSection', 'conditionBrowseModule','meshes') || @data.dig('derivedSection', 'interventionBrowseModule','meshes')
        process_mesh_term(trial)
      end

      trial.updated_at = DateTime.now # Set updated date, even if the trial has not changed.

      # Save associations.
      if @data.dig('protocolSection', 'conditionsModule','conditions')
        process_conditions(trial.id)
      end

      if @data.dig('protocolSection', 'armsInterventionsModule','interventions')
        process_interventions(trial.id)
      end

      if @data.dig('protocolSection', 'contactsLocationsModule','locations')
        process_locations(trial.id)
      end

      if @data.dig('protocolSection', 'conditionsModule','keywords')
        process_keywords(trial.id)
      end

      trial.save
      
    end

    def process_contacts(trial)

      # Overall official
      if @data.dig('protocolSection', 'contactsLocationsModule','overallOfficials')
        overall_offical = @data.dig('protocolSection', 'contactsLocationsModule','overallOfficials',0)
        
        trial.official_last_name = overall_offical['name']
        trial.official_role = overall_offical['role']
        trial.official_affiliation = overall_offical['affiliation']
      end

      # V2 api no longer has "contact" and "backup contact".
      # Use the first two of any location contacts and then central contacts (having an email address),
      #  in order, as "primary" and "backup".
      location_contacts = central_contacts = []
      if !location.dig('contacts').blank?
        location_contacts = location.dig('contacts').filter do |c|
          !c.dig("email").blank? || !c.dig("phone").blank? 
        end
      end

      if !@data.dig('protocolSection', 'contactsLocationsModule','centralContacts').blank?
        central_contacts = @data.dig('protocolSection', 'contactsLocationsModule','centralContacts').filter do |c|
          !c.dig("email").blank?
        end
      end

      all_contacts = location_contacts + central_contacts
      if !all_contacts.blank?
        c_0 = all_contacts.first
        c_1 = all_contacts.second

        if !c_0.blank?
          trial.contact_last_name = c_0["name"]
          trial.contact_phone = c_0["phone"]
          trial.contact_email =c_0["email"]
        end

        if !c_1.blank?
          trial.contact_backup_last_name = c_1["name"]
          trial.contact_backup_phone = c_1["phone"]
          trial.contact_backup_email =c_1["email"]
        end
      end
    end

    def process_eligibility(trial)
      
      if @data.dig('protocolSection', 'eligibilityModule','sex')
        trial.gender = @data.dig('protocolSection', 'eligibilityModule','sex')
      end
      
      if @data.dig('protocolSection', 'eligibilityModule','minimumAge')
        min_age = @data.dig('protocolSection', 'eligibilityModule','minimumAge')
        if min_age.blank? || min_age == "N/A"
          trial.minimum_age = nil
          trial.min_age_unit = nil
          return
        end

        trial.minimum_age = min_age.gsub(/ year(?:s)?/i, '') unless min_age.nil?
        trial.min_age_unit = min_age

        if !trial.min_age_unit.nil? and (trial.min_age_unit.include? 'Month' or trial.min_age_unit.include? 'Months')
          trial.minimum_age = (trial.minimum_age.gsub(/\D/, '').to_f / 12).round(2)
        end

        if !trial.min_age_unit.nil? and (trial.min_age_unit.include? 'Week' or trial.min_age_unit.include? 'Weeks')
          trial.minimum_age = (trial.minimum_age.gsub(/\D/, '').to_f * 0.0191781).round(2)
        end

        if !trial.min_age_unit.nil? and (trial.min_age_unit.include? 'Day' or trial.min_age_unit.include? 'Days')
          trial.minimum_age = (trial.minimum_age.gsub(/\D/, '').to_f * 0.002739728571424657).round(2)
        end

      end
      
      if @data.dig('protocolSection', 'eligibilityModule','maximumAge')
        max_age = @data.dig('protocolSection', 'eligibilityModule','maximumAge')
        if max_age.blank? || max_age == "N/A"
          trial.maximum_age = nil
          trial.max_age_unit = nil
          return
        end

        trial.maximum_age = max_age.gsub(/ year(?:s)?/i, '') unless max_age.nil?
        trial.max_age_unit = max_age

        if !trial.max_age_unit.nil? and (trial.max_age_unit.include? 'Month' or trial.max_age_unit.include? 'Months')
          trial.maximum_age = (trial.maximum_age.gsub(/\D/, '').to_f / 12).round(2)
        end

        if !trial.max_age_unit.nil? and (trial.max_age_unit.include? 'Week' or trial.max_age_unit.include? 'Weeks')
          trial.maximum_age = (trial.maximum_age.gsub(/\D/, '').to_f * 0.0191781).round(2)
        end

        if !trial.max_age_unit.nil? and (trial.max_age_unit.include? 'Day' or trial.max_age_unit.include? 'Days')
          trial.maximum_age = (trial.maximum_age.gsub(/\D/, '').to_f * 0.002739728571424657).round(2)
        end
        
      end

      if @data.dig('protocolSection', 'eligibilityModule','healthyVolunteers') == true
          trial.healthy_volunteers_imported = true
      elsif @data.dig('protocolSection', 'eligibilityModule','healthyVolunteers') == false
          trial.healthy_volunteers_imported = false
      end

      if @data.dig('protocolSection', 'eligibilityModule','eligibilityCriteria')
        trial.eligibility_criteria = @data.dig('protocolSection', 'eligibilityModule','eligibilityCriteria')
      end

    end

    def process_mesh_term(trial)
      TrialMeshTerm.where(trial_id: trial.id).delete_all
      if @data.dig('derivedSection', 'conditionBrowseModule','meshes')
        process_condition_browse(trial)
      end
      if @data.dig('derivedSection', 'interventionBrowseModule','meshes')
        process_intervention_browse(trial)
      end
    end

    def process_condition_browse(trial)
      mesh_term = @data.dig('derivedSection', 'conditionBrowseModule','meshes').map { |e| e['term'] }
      mesh_term.each do |mesh|
        test = TrialMeshTerm.create({
          trial_id: trial.id,
          mesh_term_type: 'Conditional',
          mesh_term: mesh
        })
      end
    end

    def process_intervention_browse(trial)
      mesh_term = @data.dig('derivedSection', 'interventionBrowseModule','meshes').map { |e| e['term'] }
      mesh_term.each do |mesh|
        test = TrialMeshTerm.create({
          trial_id: trial.id,
          mesh_term_type: 'Intervention',
          mesh_term: mesh
        })
      end
    end

    def process_conditions(id)
      conditions = @data.dig('protocolSection', 'conditionsModule','conditions')
      conditions = [conditions] unless conditions.instance_of?(Array)
  
      TrialCondition.where(trial_id: id).delete_all

      conditions.each do |c|
        condition = Condition.find_or_initialize_by(condition: c)
        if condition.id.nil?
          condition.save
        end

        tc = TrialCondition.create({
          trial_id: id,
          condition_id: condition.id
        })
      end
    end

    def process_interventions(id)
      interventions = @data.dig('protocolSection', 'armsInterventionsModule','interventions')
      TrialIntervention.where(trial_id: id).delete_all

      interventions.each do |i|
        TrialIntervention.create({
          trial_id: id,
          intervention_type: i['type'],
          intervention: i['name'],
          description: i['description']
        })
      end
    end

    def process_locations(id)
      locations = self.locations
      locations = [locations] unless locations.instance_of?(Array)

      TrialLocation.where(trial_id: id).delete_all
      locations.each do |l|
        facility = l.dig('facility')
        if !facility.blank? # We key off the facility name, so we can't really do anything if it doesn't exist.
          location = Location.find_or_initialize_by(location: facility)
          
          location.city = l.dig('city')
          location.state = l.dig('state')
          location.zip = l.dig('zip')
          location.country = l.dig('country')

          location.save

          tl = TrialLocation.new(trial_id: id, location_id: location.id, status: l.dig('status'))

          if !l.dig('contacts').blank?
            location_contacts = l.dig('contacts').filter do |c|
              !c.dig("email").blank?
            end

            c_0 = location_contacts.first
            c_1 = location_contacts.second

            if !c_0.blank?
              tl.last_name = c_0["name"]
              tl.phone = c_0["phone"]
              tl.email =c_0["email"]
            end

            if !c_1.blank?
              tl.backup_last_name = c_1["name"]
              tl.backup_phone = c_1["phone"]
              tl.backup_email =c_1["email"]
            end
          end

          tl.save
        end
      end
    end

    def process_keywords(id)
      
      keywords = @data.dig('protocolSection', 'conditionsModule','keywords')
      keywords = [keywords] unless keywords.instance_of?(Array)

      TrialKeyword.where(trial_id: id).delete_all

      keywords.each do |k|
        TrialKeyword.create({
          trial_id: id,
          keyword: k
        })
      end

      # TODO: Should we include the intervention "otherNames" as keywords? 
      # interventions = @data.dig('protocolSection', 'armsInterventionsModule','interventions').map { |e| e['otherNames'] }.flatten
      # interventions.each do |i|
      #   TrialKeyword.create({
      #     trial_id: id,
      #     keyword: i
      #   })
      # end

    end

    def retrieve_simple_fields(trial)
      previous_status = trial.overall_status
      
      # Look at simple fields and update where appropriate.
      @@simple_fields.each do |k,v|
        if @data.dig(*v)
          trial[k] = @data.dig(*v)
        end
      end

      trial.overall_status = calculated_status
      trial.recruiting = (calculated_status.downcase == 'recruiting')
      trial.visible = trial.recruiting
    end

  end
end
