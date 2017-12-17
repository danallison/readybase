class UsersController < ApplicationController
  def create
    user = User.new
    assign_params_to_user(user, params)
    user.app_id = current_app.id
    user.save!
    @current_user = user
    new_session!
    render json: {token: get_encrypted_token, user: sanitize(user)}
  end

  def update
    user = requested_user
    if can_edit_user?(user)
      assign_params_to_user(user, params)
      user.save!
      render json: sanitize(user)
    elsif !user
      render json: {message:'user not found'}, status: :not_found
    elsif !current_user
      render json: {message:'you must sign in to edit users'}, status: :unauthorized
    else
      render json: {message:'you do not have write access to this user'}, status: :forbidden
    end
  end

  def show
    user = requested_user
    if can_edit_user?(user)
      render json: sanitize(user)
    elsif user
      render json: sanitize(user)
    else
      render json: {message:'user not found'}, status: :not_found
    end
  end

  def index
    render json: scope.map {|user| sanitize(user) }
  end

  private

  def requested_user
    scope.find_by_unique_id(params[:id])
  end

  def assign_params_to_user(user, params)
    user.email = params[:email] if params[:email]
    user.username = params[:username] if params[:username]
    user.password = params[:password] if params[:password]
    user.data = params[:data] if params[:data]
    user.belongs_to = params[:belongs_to] if params[:belongs_to]
  end

  def can_edit_user?(user)
    user && current_user && user.id == current_user.id
  end

end
