class PermissionRegistry
  EXEMPT_CONTROLLERS = %w[sessions passwords home registrations].freeze

  # Controladores que comparten el código de menú de otro controlador.
  # Clave: controller_name  →  Valor: código de menú a usar para la verificación.
  CONTROLLER_MENU_MAP = {
    "estadisticas_periodo" => "ESTADISTICAS",
    "detalle_ventas"       => "VENTAS"
  }.freeze

  # Mapeo específico por controlador y acción
  ACTION_MENU_MAP = {
    "productos#consulta_precios" => "CONSULTA_PRECIOS"
  }.freeze

  def self.menu_code_for(controller_name, action_name = nil)
    specific_key = "#{controller_name}##{action_name}"
    return ACTION_MENU_MAP[specific_key] if action_name && ACTION_MENU_MAP.key?(specific_key)

    CONTROLLER_MENU_MAP.fetch(controller_name, controller_name.upcase)
  end

  def self.requires_menu_check?(controller_name)
    !EXEMPT_CONTROLLERS.include?(controller_name)
  end
end
