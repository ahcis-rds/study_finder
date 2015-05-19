class ContactController < ApplicationController
  def index
  end

  def create
    c = ContactForm.new(name: params[:name], email: params[:email], message: params[:message])
    if c.valid?
      c.deliver
      redirect_to contact_index_path, flash: { success: 'Thank you for your inquiry.' }
    else
      redirect_to contact_index_path, flash: { error: c.errors.full_messages }
    end
  end
end