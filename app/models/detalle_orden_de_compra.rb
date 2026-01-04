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

  # before_validation :calcular_costo_unitario

  private

  def costo_coherente_con_precio
    return unless precio_unitario_compra.present? && costo_unitario_compra_calculado.present?

    if costo_unitario_compra_calculado < precio_unitario_compra
      errors.add(:costo_unitario_compra_calculado, "No puede ser menor que el precio unitario de compra")
    end
  end

  def calcular_costo_unitario
    return unless precio_unitario_compra.present?

    self.costo_unitario_compra_calculado = precio_unitario_compra

    # 2. Lógica de Flete (Opcional pero recomendada)
    # Nota: Distribuir el flete línea por línea al guardar es complejo porque 
    # si agregas otro producto después, el prorrateo de los anteriores cambia.
    # 
    # Por ahora, esta lógica asegura que si el usuario no mete el costo manual,
    # el sistema asuma: Costo = Precio.

    # Si quisieras sumar un flete FIJO conocido por producto, sería así:
    # self.costo_unitario_compra_calculado += (orden_de_compra.costo_total_flete / cantidad) rescue 0
  end
end
