class OrdenDeCompra < ApplicationRecord
  self.table_name = "ordenes_de_compra"

  belongs_to :proveedor
  has_many :detalle_ordenes_de_compra, dependent: :destroy

  normalizes :numero_factura, with: ->(valor) { valor.strip.upcase }

  validates :proveedor, presence: { message: "es requerido" }
  validates :fecha_compra, presence: true
  validate :fecha_compra_no_futura

  validates :numero_factura,
            length: { maximum: 50 },
            allow_blank: true

  validates :numero_factura,
            uniqueness: { scope: :proveedor_id, message: "ya ha sido registrada para este proveedor" },
            if: -> { numero_factura.present? }

  validates :costo_total_flete,
            numericality: { greater_than_or_equal_to: 0 }

  scope :pendientes,   -> { where(finalizada: false) }
  scope :finalizadas,  -> { where(finalizada: true) }

  def pendiente?
    !finalizada?
  end

  def finalizar!(precios: {}, precios_mayor: {})
    return false if finalizada?

    transaction do
      aplicar_inventario!(precios: precios, precios_mayor: precios_mayor)
      update!(finalizada: true)
    end

    true
  end

  def aplicar_inventario!(precios: {}, precios_mayor: {})
    detalle_ordenes_de_compra.includes(:producto).order(:created_at).each do |detalle|
      detalle.aplicar_en_producto!

      pid = detalle.producto_id.to_s
      pv  = precios[pid]
      pm  = precios_mayor[pid]

      columnas = {}
      columnas[:precio_venta]          = pv.to_d.ceil if pv.present? && pv.to_d.ceil.positive?
      columnas[:precio_venta_al_mayor] = pm.to_d.ceil if pm.present? && pm.to_d.ceil.positive?

      detalle.producto.update_columns(columnas) if columnas.any?
    end
  end

  private

  def fecha_compra_no_futura
    return if fecha_compra.blank?

    if fecha_compra > Date.current
      errors.add(:fecha_compra, "no puede ser una fecha futura")
    end
  end
end
