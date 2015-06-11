class StudiesController < ApplicationController
  include StudiesHelper

  respond_to :html, :json
  
  def index
    if !params[:search].nil? and !params[:search][:category].nil?
      @group = StudyFinder::Group.find(params[:search][:category])
    end

    if params[:search].nil? or params[:search][:q].blank?
      # Show all trials that are visible, there were no search terms entered.
      params[:search] = {} if params[:search].nil?
      @trials = StudyFinder::Trial.match_all(params[:search]).page(params[:page]).results
    else
      # There is actually a search term here.
      # phrase_search = StudyFinder::Trial.phrase_search(params[:search]).page(params[:page]).results
      # unless phrase_search.total == 0
      #   @trials = phrase_search
      # else
        params[:search][:q] = replace_words(params[:search][:q])
        @trials = StudyFinder::Trial.match_all_search(params[:search]).page(params[:page]).results
        # if match_all.total == 0
        #   @trials = StudyFinder::Trial.match_synonyms(params[:search]).page(params[:page]).results
        # else
        #   @trials = match_all
        # end  
      # end
      if @trials.total == 0
        @suggestions = StudyFinder::Trial.suggestions(params[:search][:q])
      end
    end
  end

  def typeahead
    typeahead = StudyFinder::Trial.typeahead(params[:q])
    respond_with(typeahead['keyword_suggest'][0]['options'])
  end

  def contact_team
    @trial = StudyFinder::Trial.find params[:id]
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
    render nothing: true
  end

  def email_me
    @trial = StudyFinder::Trial.find params[:id]
    contacts = contacts_display(determine_contacts(@trial))
    eligibility = eligibility_display(@trial.gender)
    age = age_display(@trial.min_age, @trial.max_age)
    StudyMailer.email_me(params[:email], params[:notes], @trial, contacts, eligibility, age).deliver
    render nothing: true
  end

  private
    def replace_words(q)
      q.gsub('head ache', 'headache')
    end
end