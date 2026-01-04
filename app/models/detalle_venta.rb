class DetalleVenta < ApplicationRecord

  self.table_name = "detalle_ventas"

  belongs_to :venta
  belongs_to :producto

  validates :cantidad,
            presence: true,
            numericality: { greater_than: 0, only_integer: true }

  validates :precio_unitario_venta,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :precio_historico_al_momento_de_venta,
            numericality: { greater_than_or_equal_to: 0 },
            allow_blank: true

  validates :producto_id,
            uniqueness: { scope: :venta_id, message: "ya está agregado a la venta. Edite la cantidad." }


  before_validation :asignar_datos_producto, on: :create
  after_save :actualizar_total_venta
  after_destroy :actualizar_total_venta

  def subtotal
    (cantidad || 0) * (precio_unitario_venta || 0)
  end

  private

  def asignar_datos_producto
    return unless producto.present?

    self.precio_unitario_venta ||= producto.precio_venta

    self.precio_historico_al_momento_de_venta ||= producto.precio_venta
  end

  def actualizar_total_venta
    venta.update_column(:cantidad_total, venta.detalle_venta.sum("cantidad * precio_unitario_venta"))
  end
end
