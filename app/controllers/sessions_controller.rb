class SessionsController < ApplicationController
  def create
    if current_user
      current_user.regenerate_token unless current_user.token
      render json: current_user.attributes_for_api.merge(token: current_user.token)
    else
      render json: {message: 'invalid email or password'}, status: :unauthorized
    end
  end

  def destroy
    if current_user
      current_user.token = nil
      current_user.save!
      render json: {token: nil}
    else
      render json: {message:"session not found"}
    end
  end

  private

  def current_user
    return @current_user if @current_user
    if params[:email] && params[:password]
      user = current_app.users.find_by_email(params[:email])
      @current_user = user if user && user.authenticate(params[:password])
    else
      @current_user = super
    end
  end

end
