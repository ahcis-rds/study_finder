class ResearchersController < ApplicationController
  before_filter :authorize_researcher, except: [:index, :search]
  
  def index
  end

  def search
    # if we just let the before_filter check this it's going to tell the user they "don't have access to that page" which is kind wierd
    if is_researcher? || is_admin?
      add_breadcrumb 'Home', :root_path
      add_breadcrumb 'For Researchers', :researchers_path
      add_breadcrumb 'Lookup'
    else
      redirect_to new_session_path
    end
  end

  def edit
    @trial = StudyFinder::Trial.find_by(system_id: params[:id])

    add_breadcrumb 'Home', :root_path
    add_breadcrumb 'For Researchers', :researchers_path
    add_breadcrumb 'Lookup', :search_trials_researchers_path
    add_breadcrumb 'Edit Trial'
  end

  def update
    @trial = StudyFinder::Trial.find_by(system_id: params[:id])

    unless params[:secret_key].blank?
      if @trial.update(trial_params)
        redirect_to edit_researcher_path(params[:id]), flash: { success: 'Trial updated successfully' }
      else
        render 'edit'
      end
    else
      flash[:notice] = 'The secret key you entered was incorrect.'
      render 'edit'
    end
  end

  def search_results
    trial = StudyFinder::Trial.find_by(system_id: params[:id])

    if trial.nil?
      redirect_to search_trials_researchers_path, flash: { error: 'Trial does not exist in the system' }
    else
      redirect_to edit_researcher_path(trial.system_id)
    end
  end

  private
    def trial_params
      params.require(:study_finder_trial).permit(:simple_description, :contact_override, :contact_override_first_name, :contact_override_last_name)
    end

end