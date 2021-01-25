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
          first_name: trial.contact_first_name,
          last_name: trial.contact_last_name
        }
      end

      if !trial.contact_backup_email.nil? && trial.contact_backup_email.include?(contact_suffix)
        contacts << {
          email: trial.contact_backup_email,
          first_name: trial.contact_backup_first_name,
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
          first_name: trial.contact_first_name,
          last_name: trial.contact_last_name
        }
      end

      if !trial.contact_backup_email.nil?
        contacts << {
          email: trial.contact_backup_email,
          first_name: trial.contact_backup_first_name,
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

  def determine_contact_method(trial)
    if !trial.contact_url_override.blank? || !trial.contact_url.blank?
      return 'url'
    else
      return 'email'
    end
  end

  def render_contact_url(trial)
    unless trial.contact_url_override.blank?
      return trial.contact_url_override
    else
      return trial.contact_url
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
    return "#{request.path}?#{p.to_unsafe_h.to_query}"
  end

  def eligibility_display(gender)
    unless gender.blank?
      if gender == 'Both'
        'Male or Female'
      else
        gender
      end
    else
      'No info available'
    end
  end

  def render_healthy_volunteers(study)
    rendered = '<div class="healthy-message" data-toggle="popover" data-title="Healthy Volunteer" data-content="A person who does not have the condition or disease being studied." data-placement="top">'
            
    if study.healthy_volunteers == true
      rendered = rendered + '<i class="fa fa-check-circle"></i>This study is also accepting healthy volunteers <i class="fa fa-question-circle"></i>'
    else
      rendered = rendered + '<i class="fa fa-exclamation-triangle"></i>This study is NOT accepting healthy volunteers <i class="fa fa-question-circle"></i>'
    end
    rendered = rendered + '</div>'

    return rendered.html_safe
  end

  def render_study_description(study)
    if !study.simple_description.nil? && study.simple_description.length > 500
      rendered = '<div>' + study.simple_description.truncate(500) + '<i class="fa fa-question-circle" class="study-desc-popover" data-toggle="popover" data-title="Study Description" data-content="' + study.simple_description + '" data-placement="top"></i></div>'
    else 
      rendered = study.simple_description.to_s
    end
    
    return rendered.html_safe
  end

  def render_age_display(study)
     return (study.respond_to?(:min_age_unit) && study.respond_to?(:max_age_unit)) ? age_display_units(study.min_age_unit, study.max_age_unit) : age_display(study.min_age, study.max_age)
  end

  def age_display_units(min_age_unit, max_age_unit)
    if min_age_unit == 'N/A' and max_age_unit != 'N/A'
      return "up to #{max_age_unit} old"
    elsif min_age_unit != 'N/A' and max_age_unit == 'N/A'
      return "#{min_age_unit} and over"
    elsif min_age_unit == 'N/A' and max_age_unit == 'N/A'
      return "Not specified"
    else
      return "#{min_age_unit} to #{max_age_unit} old"
    end
  end

  def age_display(min_age, max_age)
    age = ''
    unless (min_age.nil? and max_age.nil?) or (min_age == 0 and max_age == 1000)
      unless min_age.nil? or min_age == 0
        unless (min_age % 1).zero?
          # There is a decimal value.  Let's convert it.
          age << "#{(min_age * 12).round} month(s)"
        else
          age << "#{min_age.to_i} year(s)"
        end
      else
        age << 'up to '
      end

      unless max_age.nil? or max_age == 1000
        unless age.include?('to')
          age << " to "
        end
        unless (max_age % 1).zero?
          # There is a decimal value.  Let's convert it.
          age << "#{(max_age * 12).round} month(s) old"
        else
          age << "#{max_age.to_i} year(s) old"
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
        contacts << "#{contact[:last_name]} - "
      end
      contacts << "#{contact[:email]}<br>"
    end
    contacts.html_safe
  end

  def site(site)
    site_name = site.site_name

    unless site.city.blank?
      site_name = site_name + ' - ' + site.city
    end

    unless site.state.blank?
      site_name = site_name + ', ' + site.state
    end

    return site_name
  end

  def render_attribute(settings, key, page, attribute, new_line = false)
    setting = settings.select{|x|x.attribute_key == key}.first
    rendered = ''
    return rendered if setting.nil?

    open_tag = (new_line == false ? '<span class="nomargin">' : '<p class="nomargin">')
    close_tag = (new_line == false ? '</span>' : '</p>')

    if page == 'show' && setting.display_on_show && !(setting.display_if_null_on_show == false && (attribute.nil? || attribute.blank?))
      #configured to show up on the page unless attribute is nil
      rendered = rendered + '<label class="nomargin strong">' + setting.attribute_label + '</label> ' if setting.display_label_on_show
      rendered = rendered + open_tag + attribute.to_s + close_tag
    elsif page == 'list' && setting.display_on_list && !(setting.display_if_null_on_list == false && (attribute.nil? || attribute.blank?))
      rendered = rendered + '<label class="nomargin strong">' + setting.attribute_label + '</label> ' if setting.display_label_on_list
      rendered = rendered + open_tag + attribute.to_s + close_tag
    end
    rendered = '<div data-attribute-name=' + setting.attribute_key + '>' + rendered + '</div>' unless rendered == ''

    return rendered.html_safe
  end
end