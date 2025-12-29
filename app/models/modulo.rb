class Modulo < ApplicationRecord
  self.table_name = "modulos"

  after_commit -> { broadcast_refresh_later_to "modulos" }

  has_many :menus, dependent: :destroy
  validates :nombre, presence: true, length: { maximum: 50 }

end
