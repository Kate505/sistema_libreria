class RolesUser < ApplicationRecord
  self.table_name = "roles_users"

  belongs_to :rol
  belongs_to :user

  after_commit :invalidate_user_sessions_if_no_active_roles, on: %i[create destroy]

  private

  def invalidate_user_sessions_if_no_active_roles
    user.invalidate_sessions_if_no_active_roles!
  end
end
