class RolesMenu < ApplicationRecord
  self.table_name = "roles_menus"

  belongs_to :rol
  belongs_to :menu
end
