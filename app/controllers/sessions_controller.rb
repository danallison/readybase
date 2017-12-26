class SessionsController < ApplicationController
  def create
    if current_user
      destroy_current_session if current_session && current_session.user_id != current_user.id
      unless current_session
        initialize_session!
      end
      render json: sanitize(current_user), status: :created
    else
      render json: {message: 'invalid email or password'}, status: :unauthorized
    end
  end

  def destroy
    if current_session && params[:id]
      # TODO Figure out correct way to allow admin to delete other users' sessions
      session = Session.where(
        app_id: current_app.id,
        user_id: current_user.id,
        id: Session.unique_id_to_id(params[:id])
      ).first
      unless session
        render json: {message:"session not found"}, status: :not_found
        return
      end
    else
      session = current_session
    end
    if session
      destroy_session(session)
      render status: :no_content
    else
      render json: {message:"invalid credentials"}, status: :unauthorized
    end
  end

  def index
    if current_session
      sessions = Session.where(app_id: current_app.id, user_id: current_user.id)
      # TODO Flag current session in collection
      render json: sessions.map(&:attributes_for_api)
    else
      render json: {message:"invalid credentials"}, status: :unauthorized
    end
  end

  private

  def destroy_session(session)
    if current_session && session
      session.delete
      cookies.delete(session_cookie_name) if session == current_session
    end
  end

  def destroy_current_session
    destroy_session(current_session)
    @current_session = nil
  end

  def current_user
    return @current_user if @current_user
    if (params[:email] || params[:username]) && params[:password]
      user = current_app.users.find_by_email_or_username(params[:email], params[:username])
      @current_user = user if user && user.authenticate(params[:password])
    else
      @current_user = super
    end
  end

end
