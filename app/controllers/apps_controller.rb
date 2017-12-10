class AppsController < ApplicationController
  def create
    if current_user
      app = App.new
      app.owner_id = current_user.id
      app.name = params[:name]
      app.public_id = public_id_param unless public_id_exists?
      app.config = params[:config] if params[:config]
      app.public_data = params[:public_data] if params[:public_data]
      app.save!
      render json: app.attributes_for_api
    else
      render json: {message:'you must sign in to create apps'}, status: :unauthorized
    end
  end

  def update
  end

  def index
    if current_user
      render json: current_user.apps.map(&:attributes_for_api)
    else
      # TODO create a public view
      render json: {message:'you must sign in to access apps'}, status: :unauthorized
    end
  end

  private

  def public_id_param
    return @public_id_param if @public_id_param
    @public_id_param = params[:id] || params[:name].gsub(/[^0-9a-z]/i, '').downcase
    @public_id_param
  end

  def public_id_exists?
    false # TODO implement this as a model validation
  end

end
