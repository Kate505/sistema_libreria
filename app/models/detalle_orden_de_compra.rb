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

  validate :costo_coherente_con_precio

  # Actualiza stock y costos del producto al registrar la línea
  after_create :aplicar_en_producto

  # Guarda los atributos necesarios antes del destroy (el record queda frozen después)
  before_destroy :capturar_atributos_para_reversion

  # Revierte el stock del producto al eliminar la línea
  after_destroy :revertir_en_producto

  private

  def aplicar_en_producto
    producto.actualizar_por_compra!(self)
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

  def costo_coherente_con_precio
    return unless precio_unitario_compra.present? && costo_unitario_compra_calculado.present?

    if costo_unitario_compra_calculado < precio_unitario_compra
      errors.add(:costo_unitario_compra_calculado, "No puede ser menor que el precio unitario de compra")
    end
  end

  def calcular_costo_unitario
    return unless precio_unitario_compra.present?

    self.costo_unitario_compra_calculado = precio_unitario_compra
  end
end
