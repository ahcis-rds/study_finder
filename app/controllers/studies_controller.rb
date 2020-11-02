class StudiesController < ApplicationController
  include StudiesHelper

  respond_to :html, :json
  
  def index
    @search_parameters = params[:search].deep_dup if !params[:search].nil?
    @attribute_settings = TrialAttributeSetting.where(system_info_id: @system_info.id)
    
    if !params[:search].nil? and !params[:search][:category].nil?
      @group = Group.find(params[:search][:category])
      
      if @group.conditions_empty?
        @search_parameters = @search_parameters.except!(:category)
      end
    end

    if params[:search].nil? or params[:search][:q].blank?
      # Show all trials that are visible, there were no search terms entered.
      @search_parameters = {} if @search_parameters.nil?
      @trials = Trial.match_all(@search_parameters).page(params[:page]).results
    else
      # There is actually a search term here.
      # phrase_search = Trial.phrase_search(params[:search]).page(params[:page]).results
      # unless phrase_search.total == 0
      #   @trials = phrase_search
      # else
        params[:search][:q] = replace_words(@search_parameters[:q])
        @search_parameters[:q] = params[:search][:q]

        @trials = Trial.match_all_search(@search_parameters).page(params[:page]).results
        # if match_all.total == 0
        #   @trials = Trial.match_synonyms(params[:search]).page(params[:page]).results
        # else
        #   @trials = match_all
        # end  
      # end
      if @trials.total == 0
        @suggestions = Trial.suggestions(@search_parameters[:q])
      end
    end

    respond_with(@trials)
  end

  def show
    unless @system_info.display_study_show_page
      redirect_to studies_path, flash: { success: 'Apologies, This page is not available.' } and return
    end
    @study = Trial.find(params[:id])
    @attribute_settings = TrialAttributeSetting.where(system_info_id: @system_info.id)

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Study-#{@study.system_id}",
        layout: 'pdf',
        template: 'studies/show.pdf.erb',
        disposition: 'attachment',
        orientation: 'portrait',
        title:  "StudyFinder Study: #{@study.system_id}",
        encoding: "utf8"
      end
    end
  end

  def typeahead
    typeahead = Trial.typeahead(params[:q])
    respond_with(typeahead['suggest']['keyword_suggest'][0]['options'])
  end

  def contact_team
    @trial = Trial.find params[:id]
    should_send = true

    if @system_info.captcha
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
        @system_info
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

    if @system_info.captcha
      should_send = verify_recaptcha
    end

    if should_send
      StudyMailer.email_me(params[:email], params[:notes], @trial, contacts, eligibility, age).deliver
    end

    head :ok
  end

  private
    def replace_words(q)
      q.gsub('head ache', 'headache').gsub('/', ' ').gsub('"', ' ')
    end
end