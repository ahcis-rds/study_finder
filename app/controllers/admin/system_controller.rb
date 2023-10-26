class Admin::SystemController < ApplicationController
  before_action :authorize_admin
  
  def index
    @system = SystemInfo.current
    redirect_to edit_admin_system_path(@system.id)
  end

  def edit
    @system = SystemInfo.find(params[:id])
    last_update = Updater.all.last
    if last_update.blank?
      @updated_at = 'never'
    else 
      @updated_at = last_update.created_at.strftime('%m-%d-%Y')
    end

    add_breadcrumb 'System Administration'
  end

  def update
    @system = SystemInfo.find(params[:id])
    last_update = Updater.all.last
    if last_update.blank?
      @updated_at = 'never'
    else 
      @updated_at = last_update.created_at.strftime('%m-%d-%Y')
    end
    
    if @system.update(system_params)
      redirect_to edit_admin_system_path(params[:id]), flash: { success: 'System information updated successfully' }
    else
      render 'edit'
    end
  end

  private
    def system_params
      params.require(:system_info).permit(
        :alert_on_empty_system_id,
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
        :google_analytics_version,
        :display_all_locations,
        :researcher_description,
        :faq_description,
        :secret_key,
        :display_keywords,
        :display_groups_page,
        :display_study_show_page,
        :enable_showcase,
        :show_showcase_indicators,
        :show_showcase_controls,
        :study_contact_bcc,
        :trial_approval,
        :healthy_volunteers_filter,
        :gender_filter,
        trial_attribute_settings_attributes: [:id, :attribute_label, :display_label_on_list, :display_on_list, :display_if_null_on_list, :display_label_on_show, :display_on_show, :display_if_null_on_show]
      )
    end
end