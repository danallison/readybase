class AppObjectsController < ApplicationController
  def create
    object = AppObject.new
    assign_params_to_object(object, params)
    object.app_id = current_app.id
    object.save!
    render json: object.attributes_for_api
  end

  def update
    object = requested_object
    if can_edit_object?(object)
      assign_params_to_object(object, params)
      object.save!
      render json: object.attributes_for_api
    elsif !object
      render json: {message:'object not found'}, status: :not_found
    elsif !current_user
      render json: {message:'you must sign in to edit objects'}, status: :unauthorized
    else
      render json: {message:'you do not have write access to this object'}, status: :forbidden
    end
  end

  def show
    object = requested_object
    if can_edit_object?(object)
      render json: object.attributes_for_api
    elsif object
      render json: object.public_attributes_for_api
    else
      render json: {message:'object not found'}, status: :not_found
    end
  end

  private

  def requested_object
    AppObject.find_by_app_id_and_unique_id(current_app.id, params[:id])
  end

  def assign_params_to_object(object, params)
    object.type = params[:type] if params[:type]
    object.belongs_to = params[:belongs_to] if params[:belongs_to]
    object.data = params[:data] if params[:data]
  end

  def can_edit_object?(object)
    # TODO
    object #&& current_user
  end

end
