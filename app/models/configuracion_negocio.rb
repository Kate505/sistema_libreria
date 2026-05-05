class ConfiguracionNegocio < ApplicationRecord
  self.table_name = "configuracion_negocio"

  # ─── Validaciones ────────────────────────────────────────────────────
  validates :margen_ganancia_meta,
            numericality: { greater_than: 0, less_than: 1 }

  validates :porcentaje_opex,
            numericality: { greater_than_or_equal_to: 0, less_than: 1 }

  validates :margen_alerta_minimo,
            numericality: { greater_than: 0, less_than: 1 }

  validate :total_deducciones_validas

  validates :ventas_proyectadas_mes,
            numericality: { greater_than_or_equal_to: 0 }

  # ─── Singleton ───────────────────────────────────────────────────────
  # Retorna el único registro de configuración, creándolo si no existe.
  def self.configuracion
    first_or_create!(
      margen_ganancia_meta:   0.40,
      porcentaje_opex:        0.20,
      ventas_proyectadas_mes: 0.0,
      margen_alerta_minimo:   0.35
    )
  end

  # ─── Cálculo de precio sugerido ──────────────────────────────────────
  # Fórmula: PrecioVenta = CostoReal / (1 - (Margen + OpEx))
  # Garantiza el % de ganancia NETA (no markup) según la lógica de negocios.
  def precio_sugerido(costo_unitario_real)
    costo = costo_unitario_real.to_d
    return BigDecimal("0") if costo <= 0

    denominador = 1.0 - (margen_ganancia_meta.to_d + porcentaje_opex.to_d)
    return nil if denominador <= 0  # configuración imposible

    (costo / denominador).round(2)
  end

  # ─── Margen actual de un producto ────────────────────────────────────
  # Retorna el margen neto real expresado como decimal (ej: 0.40 = 40%)
  # Fórmula: (PrecioVenta - Costo - GastosOp) / PrecioVenta
  def margen_actual(precio_venta, costo_real)
    pv    = precio_venta.to_d
    costo = costo_real.to_d
    return BigDecimal("0") if pv <= 0

    gastos_op = pv * porcentaje_opex.to_d
    ((pv - costo - gastos_op) / pv).round(4)
  end

  # ─── Sugerir valores desde historial ─────────────────────────────────
  # Lee los últimos N meses de gastos_operativos y ventas para calcular
  # automáticamente el % OpEx real y las ventas promedio mensuales.
  # Actualiza el registro pero NO cambia el margen_ganancia_meta (es una meta,
  # no un histórico).
  def sugerir_valores!(meses: 6)
    fecha_inicio = meses.months.ago.beginning_of_month

    # Total de gastos operativos registrados en el período
    gastos = GastoOperativo
               .where("MAKE_DATE(periodo_year, periodo_mes, 1) >= ?", fecha_inicio)
               .sum(:gran_total_gastos)
               .to_d

    # Total de ventas realizadas en el período
    ventas = Venta
               .where("fecha_venta >= ?", fecha_inicio)
               .sum(:cantidad_total)
               .to_d

    # Meses realmente disponibles en los datos (no siempre son 6)
    meses_con_datos = GastoOperativo
                        .where("MAKE_DATE(periodo_year, periodo_mes, 1) >= ?", fecha_inicio)
                        .count
    meses_efectivos = [meses_con_datos, 1].max  # evitar división por cero

    nuevo_opex        = ventas > 0 ? (gastos / ventas).round(4) : porcentaje_opex
    nuevas_ventas_mes = (ventas / meses_efectivos).round(2)

    update!(
      porcentaje_opex:        [[nuevo_opex, 0].max, 0.9999].min,  # clamp 0..99.99%
      ventas_proyectadas_mes: nuevas_ventas_mes
    )
  end

  # ─── Descripción legible ─────────────────────────────────────────────
  def descripcion_configuracion
    "Ganancia meta: #{(margen_ganancia_meta * 100).round(1)}% | " \
    "OpEx estimado: #{(porcentaje_opex * 100).round(1)}% | " \
    "Alerta si margen < #{(margen_alerta_minimo * 100).round(1)}%"
  end

  private

  def total_deducciones_validas
    return unless margen_ganancia_meta.present? && porcentaje_opex.present?

    total = margen_ganancia_meta.to_d + porcentaje_opex.to_d
    if total >= 1.0
      errors.add(:base, "El margen de ganancia (#{(margen_ganancia_meta * 100).round(1)}%) " \
                        "más el % OpEx (#{(porcentaje_opex * 100).round(1)}%) " \
                        "no pueden sumar 100% o más.")
    end
  end
end
