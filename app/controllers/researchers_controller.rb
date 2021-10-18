class ResearchersController < ApplicationController
  before_action :authorize_researcher, except: [:index, :search]
  
  def index
  end

  def search
    # if we just let the before_action check this it's going to tell the user they "don't have access to that page" which is kind wierd
    if is_researcher? || is_admin?
      add_breadcrumb 'Home', :root_path
      add_breadcrumb 'For Researchers', :researchers_path
      add_breadcrumb 'Lookup'
    else
      redirect_to new_session_path
    end
  end

  def edit
    @trial = Trial.find_by(system_id: params[:id])

    add_breadcrumb 'Home', :root_path
    add_breadcrumb 'For Researchers', :researchers_path
    add_breadcrumb 'Lookup', :search_trials_researchers_path
    add_breadcrumb 'Edit Trial'
  end

  def update
    @trial = Trial.find_by(system_id: params[:id])

    if !params[:secret_key].blank? && params[:secret_key] == @system_info.secret_key
      if @trial.update(trial_params)
        redirect_to edit_researcher_path(params[:id]), flash: { success: 'Trial updated successfully' }
      else
        flash[:notice] = 'There was an error updating the record.'
        render 'edit'
      end
    else
      flash[:notice] = 'The secret key you entered was incorrect.'
      render 'edit'
    end
  end

  def search_results
    trial = Trial.find_by(system_id: params[:id])

    if trial.nil?
      redirect_to search_trials_researchers_path, flash: { error: 'Trial does not exist in the system' }
    else
      redirect_to edit_researcher_path(trial.system_id)
    end
  end

  private
    def trial_params
      params.require(:trial).permit(:simple_description, :display_simple_description, :contact_override, :contact_override_first_name, :contact_override_last_name)
    end

end