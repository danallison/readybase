class ReadyDatabasesController < ApplicationController
  before_action :set_ready_database, only: %i[ show update destroy ]

  def index
    @ready_databases = ReadyDatabase.all

    render json: @ready_databases
  end

  def show
    render json: @ready_database
  end

  def create
    @ready_database = ReadyDatabase.new(ready_database_params)

    if @ready_database.save
      render json: @ready_database, status: :created
    else
      render json: @ready_database.errors, status: :unprocessable_entity
    end
  end

  def update
    if @ready_database.update(ready_database_params)
      render json: @ready_database
    else
      render json: @ready_database.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @ready_database.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ready_database
      scope = ReadyDatabase.where(domain: current_domain)
      @ready_database = scope.find_by(id: params[:id])
      @ready_database ||= scope.find_by(custom_id: params[:id])
      if @ready_database.nil?
        render json: { error: "database not found" }, status: :not_found
      end
    end

    # Only allow a list of trusted parameters through.
    def ready_database_params
      params.require(:ready_database).permit(:custom_id, :data)
    end
end
