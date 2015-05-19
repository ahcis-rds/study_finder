class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :system

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

  private
    def system
      @system_info = StudyFinder::SystemInfo.current
    end
end