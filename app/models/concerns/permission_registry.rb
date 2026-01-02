class PermissionRegistry

  EXEMPT_CONTROLLERS = %w[sessions passwords home registrations].freeze

  def self.menu_code_for(controller_name)
    controller_name.upcase
  end

  def self.requires_menu_check?(controller_name)
    !EXEMPT_CONTROLLERS.include?(controller_name)
  end
end
