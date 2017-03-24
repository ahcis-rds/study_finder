class ContactController < ApplicationController
  def index
  end

  def create
    should_send = true
    if @system_info.captcha
      should_send = verify_recaptcha
    end

    c = ContactForm.new(name: params[:name], email: params[:email], message: params[:message])
    if c.valid? and should_send
      c.deliver
      redirect_to contact_index_path, flash: { success: 'Thank you for your inquiry.' }
    else
      flash[:error] = c.errors.full_messages
      render 'index'
    end
  end
end
