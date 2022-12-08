class Admin::TrialsController < ApplicationController
  before_action :authorize_admin

  require 'parsers/ctgov'
  require 'parsers/oncore'

  def new
    @trial = Trial.new
    @systems = ['Ctgov', 'Oncore']

    add_breadcrumb 'Trials Administration', :admin_trials_path
    add_breadcrumb 'Edit Trial'
  end

  def preview
    if params.has_key?('trial') && params[:trial].has_key?('system_id') && !params[:trial][:system_id].blank?
      @trial = Trial.find_by(system_id: params[:trial][:system_id])

      if @trial.nil?
        parser = Parsers::Ctgov.new(params[:trial][:system_id]) # initialize the parser
        parser.load # call the api and load the xml response
        @preview = parser.preview # preview the simple fields
      else
        redirect_to admin_trials_path, alert: 'That trial already exists'
      end
    else
      redirect_to admin_trials_path, alert: 'Please enter a ClinicalTrials.gov identifier to search'
    end
  end

  def import_show
  end

  def import
    Trial.import_from_file(params[:file])
    redirect_to admin_trials_import_path, notice: "Trials Imported"
  rescue => e
    redirect_to admin_trials_import_path, alert: "Some trials may have failed to import: #{e}"
  end

  def create
    trial = Parsers::Ctgov.new(params[:trial][:system_id])
    trial.load
    trial.process

    redirect_to admin_trials_path, flash: { success: 'Trial added successfully' }
  end

  def review
    @trial = Trial.find_by(system_id: params[:id])
    @trial.reviewed = true
    @trial.save!
    redirect_to admin_trial_recent_as_path
  end

  def recent_as
    @start_date = (params[:start_date].nil?) ? (DateTime.now - 30.days).strftime('%m/%d/%Y') : params[:start_date]
    @end_date = (params[:end_date].nil?) ? DateTime.now.strftime('%m/%d/%Y') : params[:end_date]
    @attribute = params[:attribute] == "created_at" ? "created_at" : "updated_at"

    @trials = Trial.includes(:disease_sites).find_range(@start_date, @end_date, @attribute)

    add_breadcrumb 'Trials Administration'
    add_breadcrumb 'Recent Updates'

    respond_to do |format|
      format.html

      format.xls do
        response.headers['Content-Type'] = 'application/vnd.ms-excel'
        response.headers['Content-Disposition'] = "attachment; filename=\"trials_#{DateTime.now}.xls\""
        render "recent_as.xls.erb"
      end
    end
  end

  def index
    unless params[:q].nil?
      @trials = Trial.match_all_admin({ q: params[:q].downcase }).page(params[:page]).records
    else
      @trials = Trial.paginate(page: params[:page]).where(approved: true)
    end

    add_breadcrumb 'Trials Administration'
  end

  def edit
    @trial = Trial.find_by(system_id: params[:id])

    if @trial.nil?
      redirect_to admin_trials_path, alert: 'This trial does not exist'
    end

    add_breadcrumb 'Trials Administration', :admin_trials_path
    add_breadcrumb 'Edit Trial'
  end

  def update
    @trial = Trial.find_by(system_id: params[:id])

    if params[:delete_photo]
      @trial.photo.purge
    end

    if @trial.update(trial_params)
      redirect_to edit_admin_trial_path(params[:id]), flash: { success: 'Trial updated successfully' }
    else
      render 'edit'
    end
  end
  
  def all_under_review

    unless params[:q].nil?
      @trials = Trial.match_all_under_review_admin({ q: params[:q].downcase }).page(params[:page])
      
    else
      # @trials = Trial.where(approved: false).where(visible: true).order('created_at DESC')
      @trials = Trial.paginate(page: params[:page]).where(approved: false).where(visible: true).where.not(protocol_type: 'Observational - Chart Review')
    end
    
    add_breadcrumb 'Trials Administration', :admin_trials_path
    add_breadcrumb 'All Under Review'

    respond_to do |format|
      format.html
    
      format.xls do
        @trials = Trial.where(approved: false).where(visible: true).where.not(protocol_type: 'Observational - Chart Review')
        response.headers['Content-Type'] = 'application/vnd.ms-excel'
        response.headers['Content-Disposition'] = "attachment; filename=\"all_under_review_#{DateTime.now}.xls\""
        render "all_under_review.xls.erb"
      end
    end
  end

  def under_review
    @trial = Trial.find(params[:id])
    @attribute_settings = TrialAttributeSetting.where(system_info_id: @system_info.id)
    add_breadcrumb 'Trials Administration', :admin_trials_path
    add_breadcrumb 'All Under Review', :admin_all_trials_under_review_path
    add_breadcrumb 'Under Review'
  end

  def approved
    @trial = Trial.find(params[:id])
    if @trial.update(approved: true)

      @approval = Approval.create({:user_id => session[:user]["id"], :trial_id => params[:id], :approved => true})

      redirect_to admin_all_trials_under_review_path, flash:  { success: "#{@trial.brief_title} approved" }
     
    else
      redirect_to admin_all_trials_under_review_path, flash: { error: 'Something went wrong ' }
    end
  end

  private
    def trial_params
      params.require(:trial).permit(
        :cancer_yn,
        :contact_override,
        :contact_override_first_name,
        :contact_override_last_name,
        :contact_url_override,
        :featured,
        :healthy_volunteers_override,
        :irb_number,
        :photo,
        :pi_id,
        :pi_name,
        :recruiting,
        :recruitment_url,
        :reviewed,
        :simple_description,
        :visible,
        :approved,
        :display_simple_description,
        disease_site_ids: [],
        site_ids: []
        
      )
    end

end
