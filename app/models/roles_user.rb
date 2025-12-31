class RolesUser < ApplicationRecord
  self.table_name = "roles_users"

  belongs_to :rol
  belongs_to :user
end
