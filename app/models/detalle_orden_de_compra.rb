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

  # Calcula automáticamente el costo con flete prorrateado antes de guardar
  before_validation :calcular_flete_prorrateado

  # Actualiza stock, CPP y precio_venta del producto al registrar la línea
  after_create :aplicar_en_producto
  # Después de crear esta línea, recalcula el flete de los OTROS detalles de la misma orden
  after_create :recalcular_flete_otros_detalles

  # Guarda los atributos necesarios antes del destroy (el record queda frozen después)
  before_destroy :capturar_atributos_para_reversion

  # Revierte el stock del producto al eliminar la línea
  after_destroy :revertir_en_producto
  # Después de eliminar esta línea, recalcula el flete de los detalles restantes
  after_destroy :recalcular_flete_otros_detalles

  # ─── Helpers públicos ────────────────────────────────────────────────

  # Valor monetario total de esta línea (sin flete)
  def valor_linea
    precio_unitario_compra.to_d * cantidad.to_i
  end

  # Flete unitario asignado a esta línea (diferencia entre costo calculado y precio compra)
  def flete_unitario_asignado
    costo_unitario_compra_calculado.to_d - precio_unitario_compra.to_d
  end

  private

  # ─── Prorrateo de flete por valor monetario ──────────────────────────
  # Distribuye el costo total del flete de la orden entre todos los detalles
  # proporcional al valor monetario de cada línea (precio × cantidad).
  # Este es el método estándar de "Landed Cost" por valor.
  def calcular_flete_prorrateado
    return unless precio_unitario_compra.present? && cantidad.present?

    flete_total = orden_de_compra&.costo_total_flete.to_d

    if flete_total <= 0
      # Sin flete: costo calculado = precio de compra
      self.costo_unitario_compra_calculado = precio_unitario_compra
      return
    end

    # Valor de este ítem
    valor_propio = precio_unitario_compra.to_d * cantidad.to_i

    # Valor de todos los ítems YA guardados (excluyendo este mismo si es update)
    otros_detalles = orden_de_compra.detalle_ordenes_de_compra
                                    .where.not(id: id)

    valor_otros = otros_detalles.sum { |d| d.precio_unitario_compra.to_d * d.cantidad.to_i }
    valor_total = valor_propio + valor_otros

    if valor_total <= 0
      self.costo_unitario_compra_calculado = precio_unitario_compra
      return
    end

    # Prorratear flete proporcional al valor de esta línea
    flete_asignado_linea = (valor_propio / valor_total) * flete_total
    flete_unitario       = flete_asignado_linea / cantidad.to_i

    self.costo_unitario_compra_calculado = (precio_unitario_compra.to_d + flete_unitario).round(4)
  end

  # Recalcula y persiste el flete de los demás detalles de la misma orden.
  # Se llama después de create/destroy para que el nuevo prorrateo sea correcto.
  def recalcular_flete_otros_detalles
    flete_total = orden_de_compra.costo_total_flete.to_d
    return if flete_total <= 0

    detalles = orden_de_compra.detalle_ordenes_de_compra.where.not(id: id)
    return if detalles.empty?

    valor_total = detalles.sum { |d| d.precio_unitario_compra.to_d * d.cantidad.to_i }
    return if valor_total <= 0

    updates = detalles.map do |d|
      valor_linea    = d.precio_unitario_compra.to_d * d.cantidad.to_i
      flete_asignado = (valor_linea / valor_total) * flete_total
      flete_unit     = flete_asignado / d.cantidad.to_i
      nuevo_costo    = (d.precio_unitario_compra.to_d + flete_unit).round(4)

      {
        id: d.id,
        costo_unitario_compra_calculado: nuevo_costo
      }
    end

    DetalleOrdenDeCompra.upsert_all(updates, unique_by: :id) if updates.any?
  end

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
end
