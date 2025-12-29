class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :roles_users, dependent: :destroy
  has_many :roles, through: :roles_users

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def has_role?(role_name)
    roles.where(nombre: role_name.to_s.capitalize).exists?
  end

  def can_access_menu?(menu_code)
    Menu.joins(:roles)
        .where(codigo: menu_code, roles: { id: roles.ids })
        .exists?
  end

  def accessible_menus
    Menu.joins(:roles)
        .where(roles: { id: roles.ids })
        .distinct
  end

  def accessible_modulos
    modulo_ids = Modulo
                   .joins(menus: { roles_menus: { rol: :users } })
                   .where(users: { id: id }, pasivo: false)
                   .distinct
                   .pluck(:id)

    Modulo
      .where(id: modulo_ids)
      .includes(menus: [:children, :roles])
  end

  def accessible_menus_by_user
    Menu.joins(roles_menus: { rol: :users })
        .where(users: { id: id }, pasivo: false)
        .where.not(menus: { nombre: "Inicio" })
        .distinct
        .includes(:children, :roles, :modulo)
  end

  def accessible_menus_by_user_and_module(modulo_id)
    accessible_menus_by_user.select { |menu| menu.modulo_id == modulo_id }
  end
end
