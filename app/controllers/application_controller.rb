class ApplicationController < ActionController::API

  private

  def current_token
    @current_token ||= cookies[session_cookie_name]
  end

  def current_session
    return @current_session if defined?(@current_session)
    if current_token
      decrypted_token = encryptor.decrypt_and_verify(Base64.decode64(current_token))
      session_token, user_id, digest = JSON.parse(decrypted_token)
      @current_session = Session.where(token: session_token).first
      return nil if @current_session.nil?
      return @current_session = nil unless @current_session.matches_request?(request)
      return @current_session = nil if user_id != @current_session.user_id
      return @current_session = nil if digest != @current_session.digest
      @current_session.update_from_request!(request)
      @current_session
    end
  end

  def initialize_session!
    @current_session = Session.new(
      user_id: current_user.id,
      user_agent: request.user_agent,
      origin: request.origin,
      token: Session.generate_unique_secure_token,
      device_id: cookies[:readybase_device_id] || Session.generate_unique_secure_token,
      last_ip: request.remote_ip,
      expires_at: DateTime.now + 365.days # TODO check app config
    )
    @current_session.save!
    cookies[session_cookie_name] = {
      value: get_encrypted_token,
      expires: @current_session.expires_at,
      httponly: true
    }
    cookies.permanent[:readybase_device_id] = current_session.device_id
    @current_session
  end

  def cookies
    request.cookie_jar
  end

  def session_cookie_name
    "readybase_session"
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_session ? current_session.user : nil
  end

  def encryptor
    @encryptor ||= ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base)
  end

  def get_encrypted_token
    Base64.encode64(encryptor.encrypt_and_sign([
      current_session.token,
      current_user.id,
      current_session.digest,
      SecureRandom.hex(16)
    ].to_json)).gsub("\n","")
  end

  def model
    @model ||= self.class.to_s.gsub("sController", "").constantize
  end

  def scope
    return @scope if @scope
    @scope = model
    if params[:scope]
      sql = ScopeTranslator.new(current_user).translate(params[:scope])
      @scope = @scope.where(sql)
    end
    if params[:user_id]
      associated_user = User.find_by_unique_id(params[:user_id])
      scope_id = associated_user.id # This will raise if associated_user is nil
      prefix = User.unique_id_prefix
    elsif params[:app_object_id]
      if params[:associated_object_type]
        associated_object_type = params[:associated_object_type].singularize
        associated_object_scope = AppObject.where(type: associated_object_type)
      end
      associated_object = associated_object_scope.find_by_unique_id(params[:app_object_id])
      scope_id = associated_object.id # This will raise if associated_object is nil
      prefix = AppObject.unique_id_prefix
    end
    if scope_id && prefix
      @scope = @scope.where_associated(
        associated_type: prefix,
        associated_id: scope_id.to_i
      )
    end
    if params[:sort]
      # TODO
    end
    @scope
  end

  def sanitize_attrs_for_write(attrs, object)
    # NOTE This json hack is required to prevent the error:
    # "ActionController::UnfilteredParameters (unable to convert unpermitted parameters to hash)"
    attrs = JSON.parse(attrs.to_json)
    AppConfigService.sanitize_for_access(object, current_user, 'write', request.method, attrs)
  end

  def sanitize(object)
    obj = AppConfigService.sanitize_for_access(object, current_user, 'read')
    if params[:fields]
      params[:fields] = JSON.parse(params[:fields]) if params[:fields].is_a?(String)
      obj = FieldSelector.select_fields(obj, params[:fields])
    end
    obj
  end

  def sanitize_collection(collection)
    collection.map {|obj| sanitize(obj) }
  end

  def paginate(collection)
    page = (params[:page] && params[:page].to_i > 0) ? params[:page].to_i : 1
    per_page = (params[:per_page] && params[:per_page].to_i > 0) ? params[:per_page].to_i : 10
    with_record_count = params[:with_record_count] == 'true'
    with_page_count = params[:with_page_count] == 'true'
    record_count = collection.count if with_record_count || with_page_count
    page_count = (record_count.to_f / per_page).ceil if with_page_count
    offset = (page - 1) * per_page
    collection = collection.limit(per_page).offset(offset)
    paging = {
      page: page,
      per_page: per_page
    }
    paging[:record_count] = record_count if with_record_count
    paging[:page_count] = page_count if with_page_count
    [collection, paging]
  end

  def generate_paginated_response
    collection, paging = paginate(scope)
    collection = sanitize_collection(collection)
    json_response = {
      data: collection,
      paging: paging
    }
    json_response[:scope] = params[:scope] if params[:scope]
    # TODO
    # json_response[:sort] = params[:sort] if params[:sort]
    json_response[:fields] = params[:fields] if params[:fields]
    json_response
  end
end
