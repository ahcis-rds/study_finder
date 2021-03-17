class ContactForm < MailForm::Base
  attribute :name, validate: true
  attribute :email, validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :message, validate: true

  def headers
    system_info = SystemInfo.current
    {
      subject: 'StudyFinder - Contact Us',
      to: system_info.default_email,
      from: system_info.default_email
    }
  end

end