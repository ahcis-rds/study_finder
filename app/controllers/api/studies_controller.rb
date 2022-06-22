class Api::StudiesController < ApiController
  def index
    @trials = Trial.all
  end

  def show
    @trial = Trial.find_by(system_id: params[:id])
  end

  def update
    @trial = Trial.find_by(system_id: params[:id])

    @trial.transaction do
      @trial.update_keywords!(params[:keywords])
      @trial.update_conditions!(params[:conditions])
      @trial.update_locations!(params[:locations])
      @trial.update_interventions!(params[:interventions])
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

      head 201
    else
      render json: { error: @trial.errors }, status: 400
    end
  end

  def valid_attributes
    render json: { valid_attributes: api_params }
  end

  private

  def api_params
    [
      :acronym,
      :brief_summary,
      :brief_title,
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
      :official_title,
      :overall_status,
      :phase,
      :pi_id,
      :pi_name,
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
