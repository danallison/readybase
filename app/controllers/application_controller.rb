class ApplicationController < ActionController::API
  def current_user
    return @current_user if @current_user
    token = params[:token] || request.headers['X-Auth-Token']
    puts token
    @current_user = User.find_by_token(token) if token
  end
end
