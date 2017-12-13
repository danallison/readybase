class ApplicationController < ActionController::API

  private

  def current_app_public_id
    request.headers['X-App-ID']
  end

  def current_app
    @current_app ||= App.find_by_public_id(current_app_public_id)
  end

  def current_token
    @current_token ||= params[:token] || request.headers['X-Auth-Token']
  end

  def current_session
    return @current_session if @current_session
    if current_token
      decrypted_token = encryptor.decrypt_and_verify(current_token)
      app_id, session_token, user_id = JSON.parse(decrypted_token)
      return nil if app_id != current_app.id
      @current_session = Session.find_by_app_id_and_token(app_id, session_token)
      return nil unless @current_session
      raise 'unexpected user_id mismatch' if user_id != @current_session.user_id
      @current_session = nil if request.user_agent != @current_session.user_agent
      @current_session
    end
  end

  def new_session!
    @current_session = Session.create(
      app_id: current_app.id,
      user_id: current_user.id,
      user_agent: request.user_agent,
      expires_at: DateTime.now + 365.days # TODO check app config
    )
  end

  def current_user
    return @current_user if @current_user
    @current_user = current_session.user if current_session
  end

  def encryptor
    @encryptor ||= ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base)
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
