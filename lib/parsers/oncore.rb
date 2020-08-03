module Parsers
  class Oncore
    def initialize(id)
      @id = id
      @url = "http://url.to.oncore/" + id + '.json'
    end

    def load(by_nct)
      unless by_nct.nil?
        @url = @url + '?nct=true'
      end
      response = JSON.parse( HTTParty.get(@url, headers: { "Authorization" => "Token token=\"MY_AUTH_TOKEN@!\"" }).body )

      @contents = response
    end

    def contents
      @contents
    end

    def process
      oncore = @contents

      unless oncore['nct_id'].blank?
        ctgov = Trial.find_by(system_id: oncore['nct_id'])
      end
      if ctgov.nil?  
        trial = Trial.find_or_initialize_by(system_id: @id)

        trial.system_id = @id

        # Trial does not exist yet, setup defaults
        if trial.id.nil?
          trial.visible = false # By default trials are hidden until approved by an administrator.
        end

        trial.brief_title = oncore['short_title']
        trial.detailed_description = oncore['summary']
        trial.phase = oncore['phase_desc']
        trial.overall_status = oncore['status']
        
        if oncore['status'].upcase == 'OPEN TO ACCRUAL'
          trial.recruiting = true
        else
          trial.recruiting = false
        end

        if oncore['display_protocol'] == 'Y'
          trial.visible = false
        else
          trial.visible = true
        end

        if trial.simple_description.nil?
          trial.simple_description = oncore['lay_description']
        end

        unless oncore['nct_id'].blank?
          ctgov = Parsers::Ctgov.new(oncore['nct_id'])
          ctgov.load
          ctgov.process_eligibility(trial)
        end
        trial.save
      else

        # Trial already has been loaded from ctgov connector.
        # It could still be augmented with Oncore data, if appropriate.
         
        if ctgov.simple_description.nil?
          ctgov.simple_description = oncore['lay_description']
        end

        if !oncore['contacts'].empty? #and ctgov.contact_override.nil?
          contact = oncore['contacts'][0]
          ctgov.contact_override = contact['email_address']
          ctgov.contact_override_first_name = contact['first_name']
          ctgov.contact_override_last_name = contact['last_name']
        end

        ctgov.save
      end

    end
  end
end