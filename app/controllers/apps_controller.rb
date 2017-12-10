class AppsController < ApplicationController
  def create
    if current_user
      app = App.new
      app.owner_id = current_user.id
      app.public_id = public_id_param unless public_id_exists?
      assign_params_to_app(app, params)
      app.save!
      render json: app.attributes_for_api
    else
      render json: {message:'you must sign in to create apps'}, status: :unauthorized
    end
  end

  def update
    app = App.find_by_public_id(params[:id])
    if current_user_can_edit_app?(app)
      assign_params_to_app(app, params)
      app.save!
      render json: app.attributes_for_api
    elsif !app
      render json: {message:'app not found'}, status: :not_found
    elsif !current_user
      render json: {message:'you must sign in to update apps'}, status: :unauthorized
    else
      render json: {message:'you do not have write access to this app'}, status: :forbidden
    end
  end

  def index
    if current_user
      render json: current_user.apps.map(&:attributes_for_api)
    else
      # TODO create a public view
      render json: {message:'you must sign in to access apps'}, status: :unauthorized
    end
  end

  def show
    app = App.find_by_public_id(params[:id])
    if current_user_can_edit_app?(app)
      render json: app.attributes_for_api
    elsif !app
      render json: {message:'app not found'}, status: :not_found
    # TODO create public view
    elsif !current_user
      render json: {message:'you must sign in to view apps'}, status: :unauthorized
    else
      render json: {message:'you do not have access to this app'}, status: :forbidden
    end
  end

  private

  def current_app_public_id
    Rails.application.config.meta_app_id
  end

  def current_user_can_edit_app?(app)
    app && current_user && app.owner_id == current_user.id
  end

  def assign_params_to_app(app, params)
    app.name = params[:name] if params[:name]
    app.config = params[:config] if params[:config]
    app.public_data = params[:public_data] if params[:public_data]
  end

  def public_id_param
    return @public_id_param if @public_id_param
    @public_id_param = params[:id] || params[:name].gsub(/[^0-9a-z]/i, '').downcase
    @public_id_param
  end

  def public_id_exists?
    false # TODO implement this as a model validation
  end

end
