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
    if params.has_key?('study_finder_trial') && params[:study_finder_trial].has_key?('system_id') && !params[:study_finder_trial][:system_id].blank?
      @trial = Trial.find_by(system_id: params[:study_finder_trial][:system_id])

      if @trial.nil?
        parser = Parsers::Ctgov.new(params[:study_finder_trial][:system_id]) # initialize the parser
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
    trial = Parsers::Ctgov.new(params[:study_finder_trial][:system_id])
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
    @trials = Trial.includes(:disease_sites).find_range(@start_date, @end_date)

    add_breadcrumb 'Trials Administration'
    add_breadcrumb 'Recently Added'

    respond_to do |format|
      format.html

      format.xls do
        response.headers['Content-Type'] = 'application/vnd.ms-excel'
        response.headers['Content-Disposition'] = "attachment; filename=\"study_finder_trials_#{DateTime.now}.xls\""
        render "recent_as.xls.erb"
      end
    end
  end

  def index
    unless params[:q].nil?
      @trials = Trial.match_all_admin({ q: params[:q] }).page(params[:page]).records
    else
      @trials = Trial.paginate(page: params[:page])
    end

    add_breadcrumb 'Trials Administration'
  end

  def edit

    # If editing, let's take the opportunity to update the trial from ctgov.
    trial = Parsers::Ctgov.new(params[:id])
    trial.load
    trial.process

    @trial = Trial.find_by(system_id: params[:id])

    if @trial.nil?
      redirect_to admin_trials_path, alert: 'This trial does not exist'
    end

    if @trial.parser.klass == 'Parsers::Ctgov' && !Parser.find_by({ klass: 'Parsers::Oncore'}).blank?
      @oncore = Parsers::Oncore.new(@trial.system_id)
      @oncore.load(true)
    end

    add_breadcrumb 'Trials Administration', :admin_trials_path
    add_breadcrumb 'Edit Trial'
  end

  def update
    @trial = Trial.find_by(system_id: params[:id])

    if @trial.update(trial_params)
      redirect_to edit_admin_trial_path(params[:id]), flash: { success: 'Trial updated successfully' }
    else
      render 'edit'
    end
  end

  private
    def trial_params
      params.require(:study_finder_trial).permit(
        :simple_description, :visible, 
        :featured, :recruiting, :contact_override, :cancer_yn,
        :contact_override_first_name, :contact_override_last_name, :pi_name, :pi_id, :recruitment_url, 
        :reviewed, :irb_number, site_ids: [], disease_site_ids: [])
    end

end
