class ApplicationController < ActionController::API

  private

  def current_app_public_id
    params[:app_id] || Rails.application.config.meta_app_id
  end

  def current_app
    return @current_app if @current_app
    @current_app = App.find_by_public_id(current_app_public_id)
  end

  def current_token
    return @current_token if @current_token
    @current_token = params[:token] || request.headers['X-Auth-Token']
  end

  def current_user
    return @current_user if @current_user
    @current_user = current_app.users.find_by_token(current_token) if current_token
  end
end
