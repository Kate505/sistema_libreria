class Proveedor < ApplicationRecord
  self.table_name = "proveedores"

  has_many :ordenes_de_compra

  validates :nombre,
            presence: true,
            length: { maximum: 150 }

  validates :telefono,
            length: { maximum: 8 }

  validates :direccion,
            length: { maximum: 255 }
end
