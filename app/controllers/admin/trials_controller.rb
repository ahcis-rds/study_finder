class Admin::TrialsController < ApplicationController
  before_filter :authorize_admin

  require 'parsers/ctgov'
  require 'parsers/oncore'

  def new
    # trial = Parsers::Ctgov.new('NCT01794143')
    # trial.load
    # trial.process

    # raise Parsers::Oncore.new('2003NT036').process.to_yaml

    @trial = StudyFinder::Trial.new
    @systems = ['Ctgov', 'Oncore']

    add_breadcrumb 'Trials Administration', :admin_trials_path
    add_breadcrumb 'Edit Trial'
  end

  def preview
    if params.has_key?('study_finder_trial') && params[:study_finder_trial].has_key?('system_id') && !params[:study_finder_trial][:system_id].blank?
      @trial = StudyFinder::Trial.find_by(system_id: params[:study_finder_trial][:system_id])

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

  def create
    trial = Parsers::Ctgov.new(params[:study_finder_trial][:system_id])
    trial.load
    trial.process

    redirect_to admin_trials_path, flash: { success: 'Trial added successfully' }
  end

  def review
    @trial = StudyFinder::Trial.find_by(system_id: params[:id])
    @trial.reviewed = true
    @trial.save!
    redirect_to admin_trial_recent_as_path
  end

  def recent_as
    d = params.has_key?('days') ? params[:days].to_i : 30
    @trials = StudyFinder::Trial.recent_as(d.days).paginate(page: params[:page])
    add_breadcrumb 'Trials Administration'
    add_breadcrumb 'Recently Added'
  end

  def index
    unless params[:q].nil?
      @trials = StudyFinder::Trial.match_all_admin({ q: params[:q] }).page(params[:page]).records
    else
      @trials = StudyFinder::Trial.paginate(page: params[:page])
    end

    add_breadcrumb 'Trials Administration'
  end

  def edit

    # If editing, let's take the opportunity to update the trial from ctgov.
    trial = Parsers::Ctgov.new(params[:id])
    trial.load
    trial.process

    @trial = StudyFinder::Trial.find_by(system_id: params[:id])
    if @trial.nil?
      redirect_to admin_trials_path, alert: 'This trial does not exist'
    end

    if @trial.parser.klass == 'Parsers::Ctgov' && !StudyFinder::Parser.find_by({ klass: 'Parsers::Oncore'}).blank?
      @oncore = Parsers::Oncore.new(@trial.system_id)
      @oncore.load(true)
    end

    add_breadcrumb 'Trials Administration', :admin_trials_path
    add_breadcrumb 'Edit Trial'
  end

  def update
    @trial = StudyFinder::Trial.find_by(system_id: params[:id])
    if @trial.update(trial_params)
      redirect_to edit_admin_trial_path(params[:id]), flash: { success: 'Trial updated successfully' }
    else
      render 'edit'
    end
  end

  private
    def trial_params
      params.require(:study_finder_trial).permit(:simple_description, :captcha, :visible, :featured, :recruiting, :contact_override, :contact_override_first_name, :contact_override_last_name, :recruitment_url, :reviewed)
    end

end