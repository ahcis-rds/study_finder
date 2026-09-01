module ApplicationHelper

  def bootstrap_class_for flash_type
    case flash_type
      when 'success'
        'alert-success'
      when 'alert'
        'alert-danger'
      when 'error'
        'alert-danger'
      when 'notice'
        'alert-info'
      when 'recaptcha_error'
        'alert-warning'
      else
        flash_type
    end
  end

  def bootstrap_icon_for flash_type
    case flash_type
      when 'success'
        'bi-check-circle'
      when 'alert'
        'bi-exclamation-circle'
      when 'error'
        'bi-exclamation-circle'
      when 'notice'
        'bi-exclamation-circle'
      when 'recaptcha_error'
        'bi-arrow-clockwise'
      else
        flash_type
    end
  end

  def highlight(record, key)
    if record.has_key?('highlight') and record['highlight'].has_key?(key)
      record['highlight'][key][0].html_safe
    else
      record['_source'][key]
    end
  end
  
  def username_string
    ENV['username_string']
  end

end