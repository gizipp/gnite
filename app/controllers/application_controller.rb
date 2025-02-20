class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity_response
  
  private
  
  def not_found_response(exception)
    render json: { error: exception.message }, status: :not_found
  end
  
  def unprocessable_entity_response(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end
  
  def current_user
    # In a real application, this would be handled by authentication
    # For this implementation, we'll use a parameter or header
    @current_user ||= User.find(params[:user_id] || request.headers['X-User-Id'])
  end
end
