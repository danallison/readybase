class UsersController < ApplicationController
  def create
    user = User.new
    assign_params_to_user(user, params)
    user.app_id = current_app.id
    user.save!
    user.regenerate_token
    render json: user.attributes_for_api.merge(token: user.token)
  end

  def update
    if current_user && current_user.id == params[:id].to_i
      assign_params_to_user(current_user, params)
      current_user.regenerate_token if current_user.password_digest_changed?
      current_user.save!
      render json: user.attributes_for_api.merge(token: user.token)
    else
      render status: :unauthorized
    end
  end

  private

  def assign_params_to_user(user, params)
    user.email = params[:email] if params[:email]
    user.username = params[:username] if params[:username]
    user.password = params[:password] if params[:password]
    user.data = params[:data] if params[:data]
  end

end
