class AppObjectsController < ApplicationController
  def create
    object = AppObject.new
    # TODO check and validate associated_object_type
    assign_params_to_object(object, params)
    object.type ||= 'object'
    object.app_id = current_app.id
    if can_edit_object?(object)
      object.save!
      render json: object.attributes_for_api, status: :created
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
      response = object.attributes_for_api
      if params[:include]
        associations = AppObjectAssociation.where(
          app_id: current_app.id,
          object_id: object.id,
          association_name: params[:include].singularize
        )
        associated_ids_by_type = {}
        associations.each do |a|
          associated_ids_by_type[a.associated_type] ||= []
          associated_ids_by_type[a.associated_type] << a.associated_id
        end
        user_ids = associated_ids_by_type[User.unique_id_prefix]
        users = user_ids ? User.where(app_id: current_app.id, id: user_ids) : []
        object_ids = associated_ids_by_type[AppObject.unique_id_prefix]
        objects = object_ids ? AppObject.where(app_id: current_app.id, id: object_ids) : []
        response[:included] = {
          params[:include] => (users.to_a + objects.to_a).map(&:attributes_for_api)
        }
      end
      render json: response
    elsif object
      render json: object.attributes_for_api
    else
      render json: {message:'object not found'}, status: :not_found
    end
  end

  def index
    render json: scope.map(&:attributes_for_api)
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
