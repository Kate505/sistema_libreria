class Proveedor < ApplicationRecord
  self.table_name = "proveedores"

  has_many :ordenes_de_compra

  validates :nombre,
            presence: true,
            length: { maximum: 150 }

  validates :telefono,
            format: { with: /\A\d{8}\z/, message: "debe ser exactamente 8 dígitos numéricos" },
            allow_blank: true

  validates :direccion,
            length: { maximum: 255 }
end
