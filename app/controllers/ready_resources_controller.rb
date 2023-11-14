class ReadyResourcesController < ApplicationController
  before_action :set_ready_database
  before_action :set_resource_type
  before_action :set_ready_resource, only: %i[ show update destroy ]

  def index
    @ready_resources = ReadyResource.where(
      ready_database_id: @ready_database.id,
      resource_type: @resource_type,
    )
    render json: @ready_resources
  end

  def show
    render json: @ready_resource
  end

  def create
    @ready_resource = ReadyResource.new(
      ready_database_id: @ready_database.id,
      resource_type: @resource_type,
      custom_id: params[:custom_id],
      data: params[:data],
      belongs_to: params[:belongs_to] || {},
    )

    if @ready_resource.save
      render json: @ready_resource, status: :created
    else
      render json: @ready_resource.errors, status: :unprocessable_entity
    end
  end

  def update
    if @ready_resource.update(ready_resource_params)
      render json: @ready_resource
    else
      render json: @ready_resource.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @ready_resource.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ready_resource
      scope = ReadyResource.where(
        ready_database_id: @ready_database.id,
        resource_type: @resource_type,
      )
      @ready_resource = scope.find_by(id: params[:id])
      @ready_resource ||= scope.find_by(custom_id: params[:id])
      if @ready_resource.nil?
        render json: { error: "resource not found" }, status: :not_found
      end
    end

    # Only allow a list of trusted parameters through.
    def ready_resource_params
      params.require(:ready_resource).permit(:custom_id, :data, :belongs_to)
    end

    def set_ready_database
      scope = ReadyDatabase.where(domain: current_domain)
      @ready_database = scope.find_by(id: params[:db_id])
      @ready_database ||= scope.find_by(custom_id: params[:db_id])
      if @ready_database.nil?
        render json: { error: "database not found" }, status: :not_found
      end
    end

    def set_resource_type
      @resource_type = params[:resource_type].downcase.singularize
    end

end
