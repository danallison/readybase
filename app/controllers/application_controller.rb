class ApplicationController < ActionController::API
  def current_app
    return @current_app if @current_app
    @current_app = App.find_by_public_id(params[:app_id] || params[:id])
  end

  def current_user
    return @current_user if @current_user
    token = params[:token] || request.headers['X-Auth-Token']
    @current_user = current_app.users.find_by_token(token) if token
  end
end
