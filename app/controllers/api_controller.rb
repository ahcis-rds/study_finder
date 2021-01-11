class ApiController < ActionController::API
  before_action :restrict_to_authorized_tokens

  private

  def restrict_to_authorized_tokens
    unless ApiKey.exists?(token: authorization_token)
      head 401 and return
    end
  end

  def authorization_token
    request.headers["Authorization"].to_s.split(" ").last
  end
end
