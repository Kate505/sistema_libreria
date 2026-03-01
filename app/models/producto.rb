class Producto < ApplicationRecord
  self.table_name = "productos"

  belongs_to :categoria, foreign_key: "categoria_id"
  has_many :detalle_ordenes_de_compra
  has_many :detalle_ventas

  validates :sku,
            length: { maximum: 50 },
            uniqueness: true

  validates :nombre,
            presence: true,
            length: { maximum: 200 }

  validates :categoria_id,
            presence: true

  validates :descuento_maximo,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
            if: :descuento

  validates :stock_actual,
            :precio_venta,
            :precio_venta_al_mayor,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :stock_minimo_limite,
            :stock_maximo_limite,
            numericality: { greater_than_or_equal_to: 1 }

  # Llamado después de crear un DetalleOrdenDeCompra.
  # Incrementa stock, actualiza último precio de compra y recalcula CPP.
  def actualizar_por_compra!(detalle)
    transaction do
      cantidad   = detalle.cantidad.to_i
      precio     = detalle.precio_unitario_compra.to_d
      costo      = detalle.costo_unitario_compra_calculado.to_d
      stock_prev = stock_actual.to_i

      nuevo_stock = stock_prev + cantidad

      nuevo_cpp = if nuevo_stock > 0
                    ((costo_promedio_ponderado.to_d * stock_prev) + (costo * cantidad)) / nuevo_stock
                  else
                    costo
                  end

      update_columns(
        stock_actual:               nuevo_stock,
        ultimo_precio_compra:       precio,
        costo_promedio_ponderado:   nuevo_cpp.round(2)
      )
    end
  end

  # Llamado después de destruir un DetalleOrdenDeCompra.
  # Revierte el stock (mínimo 0). No revierte CPP ni último precio (conservador).
  def revertir_compra!(detalle)
    cantidad    = detalle.cantidad.to_i
    nuevo_stock = [ stock_actual.to_i - cantidad, 0 ].max
    update_column(:stock_actual, nuevo_stock)
  end
end
