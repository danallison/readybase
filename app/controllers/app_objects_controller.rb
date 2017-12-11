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

  def index
    render json: scope.map(&:public_attributes_for_api)
  end

  private

  def requested_object
    scope.find_by_unique_id(params[:id])
  end

  def scope
    return @scope if @scope
    @scope = AppObject.where(app_id: current_app.id)
    if params[:user_id]
      scope_id = User.unique_id_to_id(params[:user_id])
      prefix = User.unique_id_prefix
    elsif params[:app_object_id]
      scope_id = AppObject.unique_id_to_id(params[:app_object_id])
      prefix = AppObject.unique_id_prefix
    end
    if scope_id && prefix
      @scope = scope.where_associated(
        app_id: current_app.id,
        associated_type: prefix,
        associated_id: scope_id.to_i
      )
    end
    if params[:type]
      @scope = @scope.where(type: params[:type])
    end
    @scope
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
