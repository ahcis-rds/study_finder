class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :system

  def logged_in?
    session.has_key? :user
  end
  helper_method :logged_in?

  def current_user
    session[:user]
  end
  helper_method :current_user

  def is_admin?
    session.has_key?('role') && session['role'] == 'admin'
  end
  helper_method :is_admin?

  def is_researcher?
    session.has_key?('role') && session['role'] == 'researcher'
  end
  helper_method :is_researcher?

  def authorize_admin
    unless is_admin?
      redirect_to root_path, flash: { error: 'You do not have access to that page.' }
    end
  end
  helper_method :authorize_admin

  def authorize_researcher
    if !is_admin? && !is_researcher?
      redirect_to root_path, flash: { error: 'You do not have access to that page.' }
    end
  end
  helper_method :authorize_researcher

  def page_param
    params[:page].to_i > 0 ? params[:page].to_i : 1
  end

  private
    def system
      @system_info = SystemInfo.current
    end
end
