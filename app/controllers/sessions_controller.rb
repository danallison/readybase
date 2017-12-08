class SessionsController < ApplicationController
  def create
    user = current_app.users.find_by_email(params[:email])
    if user.authenticate(params[:password])
      user.regenerate_token unless user.token
      render json: user.attributes_for_api.merge(token: user.token)
    else
      render json: {message: 'invalid email or password'}, status: :unauthorized
    end
  end

  def destroy
    if current_user
      current_user.token = nil
      current_user.save!
    end
    render json: {token: nil}
  end

end
