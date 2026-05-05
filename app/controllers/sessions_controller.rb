class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new; end

  def create
    if (user = User.authenticate_by(params.permit(:email_address, :password)))
      unless user.has_active_roles?
        redirect_to new_session_path, alert: "Tu usuario no tiene roles activos asignados. Contacta al administrador."
        return
      end

      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
