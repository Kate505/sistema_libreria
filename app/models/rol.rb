class Rol < ApplicationRecord
  self.table_name = "roles"

  has_many :roles_menus
  has_many :menus, through: :roles_menus

  has_many :roles_users
  has_many :users, through: :roles_users

  validates :nombre, presence: true

  after_update_commit :invalidate_users_sessions_if_role_deactivated

  private

  def invalidate_users_sessions_if_role_deactivated
    return unless saved_change_to_pasivo?
    return unless pasivo?

    users.find_each(&:invalidate_sessions_if_no_active_roles!)
  end
end
