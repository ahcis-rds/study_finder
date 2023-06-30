class Api::StudiesController < ApiController
  def index
    @trials = Trial.includes(:trial_keywords, :conditions, :trial_interventions, :locations).all
  end

  def visible
    @trials = Trial.where(visible: true).pluck(:system_id)
    render json: { system_ids: @trials }, status: 200
  end

  def show
    @trial = Trial.includes(:trial_keywords, :conditions, :trial_interventions, :locations).find_by(system_id: params[:id])
  end

  def update
    @trial = Trial.find_by(system_id: params[:id])

    @trial.transaction do
      @trial.update_interventions!(params[:interventions].to_a)
      @trial.update_keywords!(params[:keywords])
      @trial.update_conditions!(params[:conditions])
      @trial.update_locations!(params[:locations])
      @trial.update!(trial_params)
    end
    if @trial.errors.none?
      head 200
    else
      render json: { error: @trial.errors }, status: 400
    end
  end

  def create
    @trial = Trial.new(trial_params)
    if @trial.save
      @trial.transaction do
        @trial.update_keywords!(params[:keywords])
        @trial.update_conditions!(params[:conditions])
        @trial.update_locations!(params[:locations])
        @trial.update_interventions!(params[:interventions])
      end 
    end
    if @trial.errors.none?
      head 201
    else
      errors = @trial.errors.messages[:system_id]
      unless errors.include? "can't be blank"
        if @trial.visible && SystemInfo.alert_on_empty_system_id
          AdminMailer.system_id_error(@trial.system_id, errors).deliver_later
        end
      end
      render json: { error: @trial.errors }, status: 400
    end
  end

  def valid_attributes
    render json: { valid_attributes: api_params }
  end

  private

  # TODO implement handling for contact display name, which is not currently a thing
  def api_params
    [
      :acronym,
      :age,
      :brief_summary,
      :brief_title,
      :contact_display_name,
      :contact_last_name,
      :contact_first_name,
      :contact_email,
      :contact_backup_display_name,
      :contact_backup_last_name,
      :contact_backup_first_name,
      :contact_backup_email,
      :contact_override,
      :contact_override_first_name,
      :contact_override_last_name,
      :detailed_description,
      :eligibility_criteria,
      :gender,
      :healthy_volunteers_imported,
      :irb_number,
      :maximum_age,
      :minimum_age,
      :max_age_unit,
      :min_age_unit,
      :nct_id,
      :official_title,
      :overall_status,
      :phase,
      :pi_id,
      :pi_name,
      :protocol_type,
      :recruiting,
      :simple_description,
      :display_simple_description,
      :system_id,
      :verification_date,
      :visible
    ]
  end

  def trial_params
    params.permit(api_params)
  end
end
