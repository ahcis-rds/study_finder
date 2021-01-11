class Api::StudiesController < ApiController
  def index
    render json: Trial.all
  end

  def show
    @trial = Trial.find_by(system_id: params[:id])

    render json: @trial
  end

  def update
    @trial = Trial.find_by(system_id: params[:id])

    if @trial.update(trial_params)
      head 200
    else
      render json: { error: @trial.errors }, status: 400
    end
  end

  private

  def trial_params
    params.permit(
      :brief_title,
      :contact_override,
      :contact_override_first_name,
      :contact_override_last_name,
      :irb_number,
      :overall_status,
      :pi_id,
      :pi_name,
      :recruiting,
      :simple_description,
      :brief_title,
      :visible
    )
  end
end
