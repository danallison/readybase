class UsersController < ApplicationController
  def create
    user = User.new
    assign_params_to_user(user, params)
    user.save!
    user.regenerate_token
    render json: user_to_json(user)
  end

  def update
    if current_user && current_user.id == params[:id].to_i
      assign_params_to_user(current_user, params)
      current_user.regenerate_token if current_user.password_digest_changed?
      current_user.save!
      render json: user_to_json(current_user)
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

  def user_to_json(user)
    user.slice(:id, :email, :username, :data, :created_at, :updated_at, :token)
  end
end
