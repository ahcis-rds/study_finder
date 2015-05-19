module StudiesHelper
  def search_value(search_params, key)
    if !search_params.nil? and search_params.has_key?(key)
      return search_params[key]
    end
  end

  def determine_contacts(trial)
    contact_suffix = @system_info.contact_email_suffix

    if !trial.contact_override.blank?
      # Always use the override, if available.
      return [{ 
        email: trial.contact_override,
        first_name: trial.contact_override_first_name,
        last_name: trial.contact_override_last_name
      }]
    elsif !contact_suffix.nil? and (
        ( !trial.contact_email.nil? and trial.contact_email.include?(contact_suffix) ) or
        ( !trial.contact_backup_email.nil? and trial.contact_backup_email.include?(contact_suffix) )
      )

      contacts = []
      if !trial.contact_email.nil? && trial.contact_email.include?(contact_suffix)
        contacts << {
          email: trial.contact_email,
          last_name: trial.contact_last_name
        }
      end

      if !trial.contact_backup_email.nil? && trial.contact_backup_email.include?(contact_suffix)
        contacts << {
          email: trial.contact_backup_email,
          last_name: trial.contact_backup_last_name
        }
      end

      return contacts
    
    elsif (!trial.contact_email.nil? or !trial.contact_backup_email.nil?) and contact_suffix.nil?
      # Use the overall contacts, if appropriate.
      contacts = []
      if !trial.contact_email.nil?
        contacts << {
          email: trial.contact_email,
          last_name: trial.contact_last_name
        }
      end

      if !trial.contact_backup_email.nil?
        contacts << {
          email: trial.contact_backup_email,
          last_name: trial.contact_backup_last_name
        }
      end

      return contacts
    elsif !trial.trial_locations.empty? && !contact_suffix.nil?
      # Overall contacts didn't work, search within locations.
      contacts = contacts_by_location(trial.trial_locations)
      if !contacts.empty?
        return contacts
      else
        return default_email
      end
    else
      # Return the default email specified in the administrator.
      return default_email
    end
  end

  def default_email
    return [{
      email: @system_info.default_email
    }]
  end

  def contacts_by_location(locations)
    location_contacts = []
    locations.each do |x|
      if !x.email.nil? && x.email.include?(@system_info.contact_email_suffix)
        location_contacts << {
          email: x.email,
          last_name: x.last_name
        }
      end

      if !x.backup_email.nil? && x.backup_email.include?(@system_info.contact_email_suffix)
        location_contacts << {
          email: x.backup_email,
          last_name: x.backup_last_name
        }
      end
    end
    return location_contacts
  end

  def remove_category_param
    p = params.dup
    p[:search] = p[:search].except('category')
    return "#{request.path}?#{p.to_query}"
  end

  def eligibility_display(gender)
    unless gender.blank?
      if gender == 'Both'
        'Male or Female'
      else
        gender
      end
    else
      'No gender available'
    end
  end

  def age_display(min_age, max_age)
    age = ''
    unless (min_age.nil? and max_age.nil?) or (min_age == 0 and max_age == 1000)
      unless min_age.nil? or min_age == 0
        if min_age < 1.0
          age << "#{(min_age * 12).round} month(s)"
        else  
          age << "#{min_age.to_i}"
        end
      else
        age << 'up to '
      end

      unless max_age.nil? or max_age == 1000
        if max_age < 1.0
          age << "#{(max_age * 12).round} month(s)"
        else
          age << " to #{max_age.to_i} year(s) old"
        end
      else
        age << ' and over'
      end
    else
      age << 'Not specified'
    end
    age
  end

  def contacts_display(c)
    contacts = ''
    c.each do |contact|
      unless contact[:first_name].nil?
        contacts << "#{contact[:first_name]} "
      end
      unless contact[:last_name].nil?
        contacts << "#{contact[:last_name]} -"
      end
      contacts << "#{contact[:email]}<br>"
    end
    contacts.html_safe
  end
end