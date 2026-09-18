class ApplicationController < ActionController::API
  include Pundit::Authorization

  attr_reader :current_user

  rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
  rescue_from ActiveRecord::DeleteRestrictionError, with: :render_conflict

  private

  def authenticate_user!
    token = bearer_token

    unless token
      render json: {
        error: "Missing authorization token"
      }, status: :unauthorized
      return
    end

    payload = JwtService.decode(token)
    @current_user = User.find_by(id: payload[:sub])

    unless @current_user
      render json: {
        error: "Invalid authorization token"
      }, status: :unauthorized
    end
  rescue JwtService::Error, ActiveRecord::RecordNotFound
    render json: {
      error: "Invalid authorization token"
    }, status: :unauthorized
  end

  def current_organization
    current_user&.organization
  end

  def bearer_token
    header = request.headers["Authorization"]
    return if header.blank?

    scheme, token = header.split(" ", 2)

    return unless scheme&.casecmp("Bearer")&.zero?
    return if token.blank?

    token
  end

  def render_forbidden
    render json: {
      error: "Forbidden"
    }, status: :forbidden
  end

  def render_conflict(exception)
    render json: {
      error: exception.message
    }, status: :conflict
  end
end
