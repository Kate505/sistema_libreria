class DetalleVenta < ApplicationRecord

  # CRÍTICO: La migración (20260103022625_create_detalle_venta.rb) crea la tabla
  # con nombre SINGULAR: :detalle_venta — no :detalle_ventas
  self.table_name = "detalle_venta"

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

  # Validar stock disponible ANTES de crear la línea
  validate :stock_suficiente, on: :create

  # Pre-llenar precio y precio histórico desde el producto
  before_validation :asignar_datos_producto, on: :create

  # Recalcular cantidad_total de la venta padre al guardar o eliminar una línea
  after_save    :actualizar_total_venta
  after_destroy :actualizar_total_venta

  # Descontar stock del producto al registrar la línea de venta
  after_create :descontar_stock

  # Capturar cantidad ANTES del destroy (el record queda frozen después del destroy)
  before_destroy :capturar_cantidad_para_restauracion

  # Restaurar stock del producto al eliminar la línea
  after_destroy :restaurar_stock

  # ── Helpers públicos ──────────────────────────────────────────────────────

  def subtotal
    (cantidad || 0) * (precio_unitario_venta || 0)
  end

  private

  # ── Callbacks privados ────────────────────────────────────────────────────

  def asignar_datos_producto
    return unless producto.present?

    self.precio_unitario_venta                ||= producto.precio_venta
    self.precio_historico_al_momento_de_venta ||= producto.precio_venta
  end

  def stock_suficiente
    return unless producto.present? && cantidad.present?

    if producto.stock_actual.to_i < cantidad.to_i
      errors.add(:cantidad, "supera el stock disponible (#{producto.stock_actual} unidades)")
    end
  end

  def actualizar_total_venta
    total = venta.detalle_ventas.sum("cantidad * precio_unitario_venta")
    venta.update_column(:cantidad_total, total)
  end

  def descontar_stock
    producto.vender!(cantidad.to_i)
  end

  def capturar_cantidad_para_restauracion
    @cantidad_capturada = cantidad.to_i
  end

  def restaurar_stock
    producto.revertir_venta!(@cantidad_capturada)
  end
end
