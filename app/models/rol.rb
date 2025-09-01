class Rol < ApplicationRecord
  self.table_name = "roles"

  has_many :roles_menus
  has_many :menus, through: :roles_menus

  has_many :roles_users
  has_many :users, through: :roles_users

  validates :nombre, presence: true
end
