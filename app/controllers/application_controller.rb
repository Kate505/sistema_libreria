class ApplicationController < ActionController::Base
  include Authentication
  include ActiveStorage::SetCurrent

  allow_browser versions: :modern
  before_action :set_layout
  before_action :authorize_menu_access_globally

  def set_layout
    @layout = user_signed_in? ? "application" : "authentication"
  end

  private

  def authorize_menu_access_globally
    return unless Current.user
    current_controller = controller_name

    return unless PermissionRegistry.requires_menu_check?(current_controller)

    required_menu = PermissionRegistry.menu_code_for(current_controller)

    if required_menu.present?
      unless Current.user.can_access_menu?(required_menu)
        handle_unauthorized_access(required_menu)
      end
    else
      Rails.logger.info "Controlador #{current_controller} no tiene mapeo de menú definido."
    end
  end

  def handle_unauthorized_access(menu_code)
    Rails.logger.warn "Acceso denegado: Usuario #{Current.user.id} intentó acceder a #{menu_code}"

    respond_to do |format|
      format.html { redirect_to root_path, alert: "No tienes permisos para acceder a este recurso." }
      format.json { render json: { error: "Unauthorized" }, status: :forbidden }
    end
  end
end
