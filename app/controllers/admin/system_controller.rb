class Admin::SystemController < ApplicationController
  before_action :authorize_admin
  
  def index
    @system = SystemInfo.current
    redirect_to edit_admin_system_path(@system.id)
  end

  def edit
    @system = SystemInfo.find(params[:id])
    @updated = Updater.all.last

    add_breadcrumb 'System Administration'
  end

  def update
    @system = SystemInfo.find(params[:id])
    @updated = Updater.all.last
    
    if @system.update(system_params)
      redirect_to edit_admin_system_path(params[:id]), flash: { success: 'System information updated successfully' }
    else
      render 'edit'
    end
  end

  private
    def system_params
      params.require(:system_info).permit(
        :initials,
        :school_name,
        :system_name,
        :system_header,
        :captcha,
        :system_description,
        :search_term,
        :default_url,
        :default_email,
        :research_match_campaign,
        :contact_email_suffix,
        :google_analytics_id,
        :display_all_locations,
        :researcher_description,
        :secret_key,
        :display_keywords,
        :display_groups_page
      )
    end
end