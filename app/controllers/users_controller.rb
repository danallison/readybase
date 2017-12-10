class UsersController < ApplicationController
  def create
    user = User.new
    assign_params_to_user(user, params)
    user.app_id = current_app.id
    user.save!
    render json: user.attributes_for_api.merge(token: user.token)
  end

  def update
    user = requested_user
    if can_edit_user?(user)
      assign_params_to_user(user, params)
      user.regenerate_token if user.password_digest_changed?
      user.save!
      render json: user.attributes_for_api
    elsif !user
      render json: {message:'user not found'}, status: :not_found
    elsif current_user
      render json: {message:'you do not have write access to this user'}, status: :forbidden
    else
      render json: {message:'you must sign in to edit users'}, status: :unauthorized
    end
  end

  def show
    user = requested_user
    if can_edit_user?(user)
      render json: user.attributes_for_api
    elsif user
      render json: user.public_attributes_for_api
    else
      render json: {message:'user not found'}, status: :not_found
    end
  end

  private

  def requested_user
    User.find_by_app_id_and_unique_id(current_app.id, params[:id])
  end

  def assign_params_to_user(user, params)
    user.email = params[:email] if params[:email]
    user.username = params[:username] if params[:username]
    user.password = params[:password] if params[:password]
    user.private_data = params[:private_data] if params[:private_data]
    user.public_data = params[:public_data] if params[:public_data]
  end

  def can_edit_user?(user)
    user && current_user && user.id == current_user.id
  end

end
