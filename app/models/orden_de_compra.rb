class OrdenDeCompra < ApplicationRecord

  self.table_name = "ordenes_de_compra"

  belongs_to :proveedor
  has_many :detalle_ordenes_de_compra, dependent: :destroy

  normalizes :numero_factura, with: ->(valor) { valor.strip.upcase }

  validates :fecha_compra, presence: true

  validates :numero_factura,
            length: { maximum: 50 },
            allow_blank: true

  validates :numero_factura,
            uniqueness: { scope: :proveedor_id, message: "ya ha sido registrada para este proveedor" },
            if: :numero_factura.present?

  validates :costo_total_flete,
            numericality: { greater_than_or_equal_to: 0 }

end
