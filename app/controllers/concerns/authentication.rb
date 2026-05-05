module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def authenticated?
    resume_session

    # Si existe una sesión pero el usuario no tiene roles activos, se invalida
    # inmediatamente para que el sistema lo trate como no autenticado.
    if Current.session && !Current.user&.has_active_roles?
      terminate_session
      return false
    end

    Current.session.present?
  end

  def require_authentication
    if resume_session
      return if Current.user&.has_active_roles?

      terminate_session if Current.session
      redirect_to new_session_path, alert: "Tu usuario no tiene roles activos asignados. Contacta al administrador."
    else
      request_authentication
    end
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
    end
  end

  def terminate_session
    return unless Current.session
    Current.session.destroy
    Current.session = nil
    cookies.delete(:session_id)
  end

  def user_signed_in?
    authenticated?
  end
end
