class SessionsController < ApplicationController
  def create
    if current_user
      unless current_session
        @current_session = Session.create(
          app_id: current_app.id,
          user_id: current_user.id,
          user_agent: request.user_agent,
          expires_at: DateTime.now + 365.days # TODO check app config
        )
      end
      token = get_encrypted_token
      render json: {token: token, user: current_user.attributes_for_api}
    else
      render json: {message: 'invalid email or password'}, status: :unauthorized
    end
  end

  def destroy
    if current_session
      current_session.delete
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

  def get_encrypted_token
    encryptor.encrypt_and_sign([
      current_app.id,
      current_session.token,
      current_user.id,
      current_session.user_agent,
      current_session.expires_at,
      SecureRandom.hex(4)
    ].to_json)
  end

end
