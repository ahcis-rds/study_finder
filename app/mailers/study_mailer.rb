class StudyMailer < ActionMailer::Base

  def contact_team(to, name, email, phone, message, system_id, brief_title, system_info)
    @name = name
    @email = email
    @phone = phone
    @message = message
    @system_id = system_id
    @brief_title = brief_title
    @system_info = system_info

    from = %("#{name}" <#{email}>)

    mail(from: @system_info.default_email, to: to, bcc: @system_info.study_contact_bcc, reply_to: email, subject: "Someone is interested in your study")
  end

  def email_me(email, message, trial, contacts, eligibility, age)
    @email = email
    @message = message
    @trial = trial
    @contacts = contacts
    @eligibility = eligibility
    @age = age
    @conditions = @trial.conditions_map
    @interventions = @trial.interventions
    @system_info = SystemInfo.current

    mail(from: @system_info.default_email, to: email, bcc: @system_info.default_email, reply_to: email, subject: "StudyFinder - #{trial.brief_title}")
  end

end