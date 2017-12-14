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
      decrypted_token = encryptor.decrypt_and_verify(Base64.decode64(current_token))
      app_id, session_token, user_id, user_agent = JSON.parse(decrypted_token)
      return nil if app_id != current_app.id
      @current_session = Session.find_by_app_id_and_token(app_id, session_token)
      return nil unless @current_session
      raise 'unexpected user_id mismatch' if user_id != @current_session.user_id
      raise 'unexpected user_agent mismatch' if user_agent != @current_session.user_agent
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
    Base64.encode64(encryptor.encrypt_and_sign([
      current_app.id,
      current_session.token,
      current_user.id,
      current_session.user_agent,
      current_session.expires_at,
      SecureRandom.hex(16)
    ].to_json)).gsub("\n","")
  end

  def model
    @model ||= self.class.to_s.gsub("sController", "").constantize
  end

  def scope
    return @scope if @scope
    @scope = model.where(app_id: current_app.id)
    if params[:user_id]
      associated_user_scope = User.where(app_id: current_app.id)
      associated_user = associated_user_scope.find_by_unique_id(params[:user_id])
      scope_id = associated_user.id # This will raise if associated_user is nil
      prefix = User.unique_id_prefix
    elsif params[:app_object_id]
      associated_object_scope = AppObject.where(app_id: current_app.id)
      if params[:associated_object_type]
        associated_object_type = params[:associated_object_type].singularize
        associated_object_scope = associated_object_scope.where(type: associated_object_type)
      end
      associated_object = associated_object_scope.find_by_unique_id(params[:app_object_id])
      scope_id = associated_object.id # This will raise if associated_object is nil
      prefix = AppObject.unique_id_prefix
    end
    if scope_id && prefix
      @scope = scope.where_associated(
        app_id: current_app.id,
        associated_type: prefix,
        associated_id: scope_id.to_i
      )
    end
    @scope
  end

  def render(options)
    options[:json] = options[:json].to_json unless options[:json].is_a?(String)
    # Assuming 8-bit characters
    byte_count = options[:json].length.bytes
    puts "BYTES => #{byte_count}"
    super(options)
  end
end
