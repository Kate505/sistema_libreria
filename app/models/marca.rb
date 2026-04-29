class Marca < ApplicationRecord
  self.table_name = "marcas"

  has_many :productos

  validates :nombre, presence: true, uniqueness: true, length: { maximum: 100 }
end
