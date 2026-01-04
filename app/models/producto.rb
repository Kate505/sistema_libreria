class Producto < ApplicationRecord
  self.table_name = "productos"

  belongs_to :categoria
  has_many :detalle_ordenes_de_compra
  has_many :detalle_ventas

  validates :sku,
            presence: true,
            length: { maximum: 50 },
            uniqueness: true

  validates :nombre,
            presence: true,
            length: { maximum: 200 }

  validates :descuento_maximo,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 },
            if: :descuento

  validates :stock_actual,
            :precio_venta,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :stock_minimo_limite,
            :stock_maximo_limite,
            numericality: { greater_than_or_equal_to: 1 }

end
