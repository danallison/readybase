class AppObjectsController < ApplicationController
  def create
    object = AppObject.new
    # TODO check and validate associated_object_type
    assign_params_to_object(object, params)
    object.type ||= 'object'
    object.app_id = current_app.id
    if can_edit_object?(object)
      object.save!
      render json: object.attributes_for_api
    else
      # TODO
      render json: {message:'forbidden'}, status: :forbidden
    end
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

  def index
    render json: scope.map(&:public_attributes_for_api)
  end

  private

  def requested_object
    scope.find_by_unique_id(params[:id])
  end

  def scope
    return @scope if @scope
    @scope = super
    if params[:type] || params[:object_type]
      params[:type] = params[:object_type] if params[:object_type]
      @scope = @scope.where(type: params[:type].singularize)
    end
    @scope
  end

  def assign_params_to_object(object, params)
    params[:type] = params[:object_type] if params[:object_type]
    object.type = params[:type].singularize if params[:type]
    object.belongs_to = params[:belongs_to] if params[:belongs_to]
    object.data = params[:data] if params[:data]
  end

  def can_edit_object?(object)
    # TODO
    object #&& current_user
  end

end
