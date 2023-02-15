class AdminMailer < ApplicationMailer

  def system_id_error(system_id, errors)
    @system_id = system_id
    @errors = errors
    @system_info = SystemInfo.current
    mail(from: @system_info.default_email, to: @system_info.default_email, reply_to:  @system_info.default_email, subject: "#{system_id} is invalid, requires update.")
  end
end
