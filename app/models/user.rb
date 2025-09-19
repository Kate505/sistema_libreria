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
    Modulo.joins(menus: { roles_menus: { rol: :users } })
          .where(users: { id: id })
          .distinct
  end

  def accessible_menus_by_user
    Menu.joins(roles_menus: { rol: :users })
        .where(users: { id: id }, menus: { nombre: not('inicio') })
        .distinct
  end

  def accessible_menus_by_user_and_module(modulo_id)
    Menu.joins(roles_menus: { rol: :users })
        .where(users: { id: id }, menus: { modulo_id: modulo_id })
        .where.not(menus: { nombre: "Inicio" })
        .distinct
  end
end
