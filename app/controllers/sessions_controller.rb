class SessionsController < ApplicationController
  require 'modules/ldap'

  def new
    @user = StudyFinder::User.new
  end

  def create
    ldap = Modules::Ldap.new.authenticate(params[:study_finder_user][:internet_id], params[:study_finder_user][:password])

    # passed ldap authentication, still need to have an account in Study Finder
    if ldap[:success] == true

      # look the user up in Study Finder
      user = StudyFinder::User.find_by(internet_id: params[:study_finder_user][:internet_id])

      # user has an account in Study Finder, set them to admin
      unless user.nil?
        # update login stats and return the user object
        user.sign_in_count += 1
        user.last_sign_in_at = Time.now
        user.last_sign_in_ip = request.remote_ip
        user.save!

        session[:user] = user
        session[:role] = 'admin'
        redirect_to admin_trials_path, flash: { success: 'You\'ve signed in successfully!' }

      # the user isn't in Study Finder, set them to researcher
      else
        # stuff the ldap info into a user model to be stored in the session
        # logger.debug ldap[:ldap_user].cn.first.to_s
        researcher = StudyFinder::User.new
        researcher.internet_id = ldap[:ldap_user].uid.first
        researcher.first_name = ldap[:ldap_user].givenname.first
        researcher.last_name = ldap[:ldap_user].sn.first
        researcher.email = ldap[:ldap_user].mail.first
        researcher.last_sign_in_at = Time.now
        researcher.last_sign_in_ip = request.remote_ip

        session[:user] = researcher
        session[:role] = 'researcher'
        redirect_to search_trials_researchers_path, flash: { success: 'You\'ve signed in successfully!' }
      end
    # the user didn't pass ldap authentication, kick them out
    else
      redirect_to new_session_path, flash: { error: 'There was a problem signing in.' }
    end
  end

  def destroy
    session.delete :user
    session.delete :role
    redirect_to root_path, flash: { notice: 'You\'ve signed out successfully!' }
  end

end
