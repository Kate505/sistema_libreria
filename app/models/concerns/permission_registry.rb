class PermissionRegistry
  EXEMPT_CONTROLLERS = %w[sessions passwords home registrations].freeze

  # Controladores o acciones específicas que comparten o tienen un código de menú propio.
  # Clave: controller_name o "controller_name#action_name"  →  Valor: código de menú a usar para la verificación.
  CONTROLLER_MENU_MAP = {
    "estadisticas_periodo"     => "ESTADISTICAS",
    "detalle_ventas"           => "VENTAS",
    "detalle_ordenes_de_compra" => "ORDENES_DE_COMPRA",
    "productos#consulta_precios" => "CONSULTA_PRECIOS"
  }.freeze

  def self.menu_code_for(controller_name, action_name = nil)
    if action_name.present?
      specific_key = "#{controller_name}##{action_name}"
      return CONTROLLER_MENU_MAP[specific_key] if CONTROLLER_MENU_MAP.key?(specific_key)
    end
    CONTROLLER_MENU_MAP.fetch(controller_name, controller_name.upcase)
  end

  def self.requires_menu_check?(controller_name)
    !EXEMPT_CONTROLLERS.include?(controller_name)
  end
end
