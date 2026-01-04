class Proveedor < ApplicationRecord
  self.table_name = "proveedores"

  has_many :ordenes_de_compra

  validates :nombre,
            presence: true,
            length: { maximum: 150 }

  validates :telefono,
            presence: true,
            length: { maximum: 11 }

  validates :direccion,
            presence: true,
            length: { maximum: 255 }

end
