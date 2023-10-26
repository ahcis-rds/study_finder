class StudiesController < ApplicationController
  include StudiesHelper

  respond_to :html, :json
  
  def index
    search_hash = search_params.to_h[:search] || {}

    @attribute_settings = SystemInfo.trial_attribute_settings
    @group = Group.where(id: search_hash[:category]).first
    @trials = Trial.execute_search(search_hash).page(search_params[:page]).results
    @search_query = search_hash[:q].try(:downcase) || ""
    @search_category = search_hash[:category].to_i
    
    if @trials.empty?
      @suggestions = Trial.suggestions(@search_query)
    end

    respond_with(@trials)
  end

  def show
    @study = Trial.find(params[:id])
    unless @study.visible 
      unless is_admin?
        redirect_to studies_path, flash: { success: 'Apologies, this page is not available.' } and return
      end
    end
    @attribute_settings = SystemInfo.trial_attribute_settings
    @study_photo = @study.photo.attached? ? @study.photo : "flag.jpg"

    respond_to do |format|
      format.html do
        unless SystemInfo.display_study_show_page
          redirect_to studies_path, flash: { success: 'Apologies, this page is not available.' } and return
        end
      end
      format.pdf do
        render pdf: "Study-#{@study.system_id}",
        layout: 'pdf',
        template: 'studies/show',
        disposition: 'attachment',
        orientation: 'portrait',
        title:  "StudyFinder Study: #{@study.system_id}",
        encoding: "utf8"
      end
    end
  end

  def typeahead
    respond_with(Trial.typeahead(params[:q].try(:downcase)))
  end

  def contact_team
    @trial = Trial.find params[:id]
    should_send = true

    if SystemInfo.captcha
      should_send = verify_recaptcha
    end

    if should_send
      StudyMailer.contact_team(
        params[:to],
        params[:name],
        params[:email],
        params[:phone],
        params[:notes],
        @trial.system_id,
        @trial.brief_title,
        SystemInfo.current
      ).deliver
    end

    head :ok
  end

  def email_me
    @trial = Trial.find params[:id]
    contacts = contacts_display(determine_contacts(@trial))
    eligibility = eligibility_display(@trial.gender)
    age = age_display(@trial.min_age, @trial.max_age)
    should_send = true

    if SystemInfo.captcha
      should_send = verify_recaptcha
    end

    if should_send
      StudyMailer.email_me(params[:email], params[:notes], @trial, contacts, eligibility, age).deliver
    end

    head :ok
  end

  private

  def search_params
    params.permit(:page, search: [:category, :q, :healthy_volunteers, :gender, :children, :adults])
  end
end
