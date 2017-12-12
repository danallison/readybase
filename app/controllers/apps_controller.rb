class AppsController < ApplicationController
  def create
    if current_user
      app = App.new
      app.owner_id = current_user.id
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

  def current_user_can_edit_app?(app)
    app && current_user && app.owner_id == current_user.id
  end

  def assign_params_to_app(app, params)
    app.name = params[:name] if params[:name]
    app.config = params[:config] if params[:config]
    app.public_data = params[:public_data] if params[:public_data]
  end

end
