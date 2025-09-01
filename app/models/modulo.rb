class Modulo < ApplicationRecord
  self.table_name = "modulos"

  has_many :menus, dependent: :destroy
  validates :nombre, presence: true, length: { maximum: 50 }

end
