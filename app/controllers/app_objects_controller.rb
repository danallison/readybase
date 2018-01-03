class AppObjectsController < ApplicationController
  def create
    object = AppObject.new
    # TODO check and validate associated_object_type
    assign_params_to_object(object, params)
    object.type ||= 'object'
    object.app_id = current_app.id
    if can_edit_object?(object)
      object.save!
      render json: sanitize(object), status: :created
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
      render json: sanitize(object)
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
      response = object.readable_attributes
      if params[:attach]
        associations = AppObjectAssociation.where(
          app_id: current_app.id,
          object_id: object.id,
          association_name: params[:attach].singularize
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
        response[:attached] = {
          params[:attach] => (users.to_a + objects.to_a).map {|obj| sanitize(obj) }
        }
      end
      render json: response
    elsif object
      render json: sanitize(object)
    else
      render json: {message:'object not found'}, status: :not_found
    end
  end

  def index
    render json: generate_paginated_response
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

    attrs = {}
    attrs[:type] = params[:type] if params[:type]
    attrs[:data] = params[:data] if params[:data]
    attrs[:belongs_to] = params[:belongs_to] if params[:belongs_to]
    attrs = sanitize_attrs_for_write(attrs, object).with_indifferent_access

    object.type = attrs[:type].singularize if attrs[:type]
    if attrs[:belongs_to]
      object.belongs_to = ApplicationService.merge_recursively(
        object.belongs_to || {},
        attrs[:belongs_to],
        {compact: true, append_arrays: params[:append_arrays]}
      )
    end
    if attrs[:data]
      object.data = ApplicationService.merge_recursively(
        object.data || {},
        attrs[:data],
        {compact: true, append_arrays: params[:append_arrays]}
      )
    end
  end

  def can_edit_object?(object)
    # TODO
    object #&& current_user
  end

end
