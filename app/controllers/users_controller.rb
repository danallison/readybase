class UsersController < ApplicationController
  def create
    user = User.new
    assign_params_to_user(user, params)
    user.save!
    unless current_session
      @current_user = user
      initialize_session!
    end
    render json: sanitize(user), status: :created
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
    render json: generate_paginated_response
  end

  private

  def requested_user
    scope.find_by_unique_id(params[:id])
  end

  def assign_params_to_user(user, params)
    attrs = {}
    attrs[:email] = params[:email] if params[:email]
    attrs[:username] = params[:username] if params[:username]
    attrs[:password] = params[:password] if params[:password]
    attrs[:data] = params[:data] if params[:data]
    attrs[:belongs_to] = params[:belongs_to] if params[:belongs_to]
    attrs[:roles] = params[:roles] if params[:roles]
    attrs = sanitize_attrs_for_write(attrs, user).with_indifferent_access

    user.email = attrs[:email] if attrs[:email]
    user.username = attrs[:username] if attrs[:username]
    user.password = attrs[:password] if attrs[:password]
    if attrs[:belongs_to]
      user.belongs_to = ApplicationService.merge_recursively(
        user.belongs_to || {},
        attrs[:belongs_to],
        {compact: true, merge_arrays: params[:merge_arrays]}
      )
    end
    if attrs[:data]
      user.data = ApplicationService.merge_recursively(
        user.data || {},
        attrs[:data],
        {compact: true, merge_arrays: params[:merge_arrays]}
      )
    end
  end

  def can_edit_user?(user)
    user # NOTE No longer hard coding permission logic, delegating to app config
  end

end
