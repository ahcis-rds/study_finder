class Admin::SystemController < ApplicationController
  before_filter :authorize_admin
  
  def index
    @system = StudyFinder::SystemInfo.current
    redirect_to edit_admin_system_path(@system.id)
  end

  def edit
    @system = StudyFinder::SystemInfo.find(params[:id])
    @updated = StudyFinder::Updater.all.last

    add_breadcrumb 'System Administration'
  end

  def update
    @system = StudyFinder::SystemInfo.find(params[:id])
    if @system.update(system_params)
      redirect_to edit_admin_system_path(params[:id]), flash: { success: 'System information updated successfully' }
    else
      render 'edit'
    end
  end

  private
    def system_params
      params.require(:study_finder_system_info).permit(
        :initials,
        :school_name,
        :system_name,
        :system_header,
        :system_description,
        :search_term,
        :default_url,
        :default_email,
        :research_match_campaign,
        :contact_email_suffix,
        :google_analytics_id,
        :display_all_locations,
        :secret_key
      )
    end
end