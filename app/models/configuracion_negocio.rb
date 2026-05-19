class ConfiguracionNegocio < ApplicationRecord
  self.table_name = "configuracion_negocio"

  # ─── Validaciones ────────────────────────────────────────────────────
  validates :margen_ganancia_meta,
            numericality: { greater_than: 0, less_than: 1 }

  validates :margen_alerta_minimo,
            numericality: { greater_than: 0, less_than: 1 }

  # ─── Singleton ───────────────────────────────────────────────────────
  # Retorna el único registro de configuración, creándolo si no existe, y lo cachea por request.
  def self.configuracion
    Current.configuracion_negocio ||= first_or_create!(
      margen_ganancia_meta: 0.40,
      margen_alerta_minimo: 0.35
    )
  end

  # ─── Cálculo de precio sugerido ──────────────────────────────────────
  # Fórmula: PrecioVenta = CostoReal / (1 - % Ganancia)
  # Siempre redondeado al entero superior (ceil).
  def precio_sugerido(costo_unitario_real)
    costo = costo_unitario_real.to_d
    return BigDecimal("0") if costo <= 0

    denominador = 1.0 - margen_ganancia_meta.to_d
    return nil if denominador <= 0  # configuración imposible

    (costo / denominador).ceil
  end

  # ─── Margen actual de un producto ────────────────────────────────────
  # Retorna el margen neto real expresado como decimal (ej: 0.40 = 40%)
  # Fórmula: (PrecioVenta - Costo) / PrecioVenta
  def margen_actual(precio_venta, costo_real)
    pv    = precio_venta.to_d
    costo = costo_real.to_d
    return BigDecimal("0") if pv <= 0

    ((pv - costo) / pv).round(4)
  end

  # ─── Descripción legible ─────────────────────────────────────────────
  def descripcion_configuracion
    "Ganancia meta: #{(margen_ganancia_meta * 100).round(1)}% | " \
    "Alerta si margen < #{(margen_alerta_minimo * 100).round(1)}%"
  end
end
