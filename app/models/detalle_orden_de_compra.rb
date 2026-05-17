require "ostruct"

class DetalleOrdenDeCompra < ApplicationRecord
  self.table_name = "detalle_ordenes_de_compra"

  belongs_to :orden_de_compra
  belongs_to :producto

  validates :cantidad,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }

  validates :precio_unitario_compra,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :costo_unitario_compra_calculado,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :producto_id,
            uniqueness: {
              scope: :orden_de_compra_id,
              message: "El producto ya ha sido agregado a esta orden de compra"
            }

  # ─── Callbacks ───────────────────────────────────────────────────────

  # Asegura que el costo calculado no esté vacío para pasar las validaciones antes de que el servicio de flete lo recalcule
  before_validation :asignar_costo_por_defecto, on: :create

  # Guarda los atributos necesarios antes del destroy (el record queda frozen después)
  before_destroy :capturar_atributos_para_reversion

  # ─── Helpers públicos ────────────────────────────────────────────────

  # Valor monetario total de esta línea (sin flete)
  def valor_linea
    precio_unitario_compra.to_d * cantidad.to_i
  end

  # Flete unitario asignado a esta línea (diferencia entre costo calculado y precio compra)
  def flete_unitario_asignado
    costo_unitario_compra_calculado.to_d - precio_unitario_compra.to_d
  end

  # Aplica el impacto en inventario cuando la orden se finaliza.
  def aplicar_en_producto!
    producto.actualizar_por_compra!(self)
  end

  private

  def asignar_costo_por_defecto
    self.costo_unitario_compra_calculado ||= precio_unitario_compra
  end

  def capturar_atributos_para_reversion
    @atributos_compra = {
      cantidad:                        cantidad,
      precio_unitario_compra:          precio_unitario_compra,
      costo_unitario_compra_calculado: costo_unitario_compra_calculado
    }
  end

  def revertir_en_producto
    detalle_virtual = OpenStruct.new(@atributos_compra)
    producto.revertir_compra!(detalle_virtual)
  end
end
