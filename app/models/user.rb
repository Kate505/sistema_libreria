class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :roles_users, dependent: :destroy
  has_many :roles, through: :roles_users, source: :rol

  belongs_to :empleado

  delegate :nombre_completo,
           :nombre_corto,
           :cargo, to: :empleado, allow_nil: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Un usuario solo debe poder autenticarse si tiene al menos un rol activo.
  # Se considera "activo" cuando el rol tiene `pasivo: false`.
  def has_active_roles?
    roles.where(pasivo: false).exists?
  end

  # Destruye todas las sesiones activas del usuario (logout forzado).
  def invalidate_sessions!
    sessions.destroy_all
  end

  # Si el usuario ya no tiene roles activos, se cierran sus sesiones.
  def invalidate_sessions_if_no_active_roles!
    invalidate_sessions! unless has_active_roles?
  end

  def has_role?(role_name)
    roles.where(nombre: role_name.to_s.capitalize, pasivo: false).exists?
  end

  def can_access_menu?(menu_code)
    Menu.joins(:roles)
        .where(codigo: menu_code, roles: { id: roles.ids, pasivo: false })
        .exists?
  end

  def accessible_menus
    Menu.joins(:roles)
        .where(roles: { id: roles.ids, pasivo: false })
        .distinct
  end

  def accessible_modulos
    modulo_ids = Modulo
                   .joins(menus: { roles_menus: { rol: :users } })
                   .where(users: { id: id, pasivo: false }, pasivo: false)
                   .distinct
                   .pluck(:id)

    Modulo
      .where(id: modulo_ids)
      .includes(menus: [ :children, :roles ])
  end

  def accessible_menus_by_user
    @accessible_menus_by_user ||= Menu.joins(roles_menus: { rol: :users })
                                      .where(users: { id: id, pasivo: false }, pasivo: false)
                                      .where.not(menus: { nombre: "Inicio" })
                                      .distinct
                                      .includes(:children, :roles, :modulo)
                                      .to_a
  end

  def accessible_menus_by_user_and_module(modulo_id)
    accessible_menus_by_user.select { |menu| menu.modulo_id == modulo_id && menu.menu_id.nil? }
  end

  scope :activos, -> { where(pasivo: false) }
end
