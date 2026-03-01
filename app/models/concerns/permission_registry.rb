class PermissionRegistry

  EXEMPT_CONTROLLERS = %w[sessions passwords home registrations].freeze

  # Controladores que comparten el código de menú de otro controlador.
  # Clave: controller_name  →  Valor: código de menú a usar para la verificación.
  CONTROLLER_MENU_MAP = {
    "nomina_empleados" => "DETALLE_PAGOS_EMPLEADOS",
    "estadisticas_periodo" => "ESTADISTICAS"
  }.freeze

  def self.menu_code_for(controller_name)
    CONTROLLER_MENU_MAP.fetch(controller_name, controller_name.upcase)
  end

  def self.requires_menu_check?(controller_name)
    !EXEMPT_CONTROLLERS.include?(controller_name)
  end
end
