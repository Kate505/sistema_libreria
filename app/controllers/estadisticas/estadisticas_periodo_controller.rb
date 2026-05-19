# frozen_string_literal: true

class Estadisticas::EstadisticasPeriodoController < ApplicationController
  def index
    hoy = Time.current

    # ── Parsear filtros de fecha ─────────────────────────────────────────────
    @fecha_desde = parse_date(params[:fecha_desde]) || hoy.beginning_of_month
    @fecha_hasta = parse_date(params[:fecha_hasta]) || hoy.end_of_day
    @fecha_hasta = @fecha_hasta.end_of_day if @fecha_hasta.respond_to?(:end_of_day)
    @marca_id    = params[:marca_id]

    rango = @fecha_desde..@fecha_hasta

    # ── KPI Financieros ──────────────────────────────────────────────────────

    if @marca_id.present?
      # Ingresos brutos: suma de detalles de venta de la marca
      @ingresos_brutos = DetalleVenta.joins(:venta, :producto)
                                     .where(ventas: { fecha_venta: rango, finalizada: true }, productos: { marca_id: @marca_id })
                                     .sum("detalle_venta.cantidad * detalle_venta.precio_unitario_venta").to_f

      @total_ventas_count = Venta.finalizadas.joins(detalle_ventas: :producto)
                                 .where(fecha_venta: rango, productos: { marca_id: @marca_id })
                                 .distinct.count

      # Costo de compras (órdenes de compra) de la marca
      @costo_compras = DetalleOrdenDeCompra
        .joins(:orden_de_compra, :producto)
        .where(ordenes_de_compra: { fecha_compra: rango, finalizada: true }, productos: { marca_id: @marca_id })
        .sum("detalle_ordenes_de_compra.precio_unitario_compra * detalle_ordenes_de_compra.cantidad").to_f

      # COGS de la marca
      @cogs = DetalleVenta
        .joins(:venta, :producto)
        .where(ventas: { fecha_venta: rango, finalizada: true }, productos: { marca_id: @marca_id })
        .sum("detalle_venta.cantidad * productos.costo_promedio_ponderado").to_f
    else
      # Ingresos brutos: suma de ventas en el período
      @ingresos_brutos      = Venta.finalizadas.where(fecha_venta: rango).sum(:cantidad_total).to_f
      @total_ventas_count   = Venta.finalizadas.where(fecha_venta: rango).count

      # Costo de compras (órdenes de compra) en el período
      @costo_compras = DetalleOrdenDeCompra
        .joins(:orden_de_compra)
        .where(ordenes_de_compra: { fecha_compra: rango, finalizada: true })
        .sum("detalle_ordenes_de_compra.precio_unitario_compra * detalle_ordenes_de_compra.cantidad").to_f

      # Costo de los productos vendidos (COGS) basado en costo promedio ponderado
      @cogs = DetalleVenta
        .joins(:venta, :producto)
        .where(ventas: { fecha_venta: rango, finalizada: true })
        .sum("detalle_venta.cantidad * productos.costo_promedio_ponderado").to_f
    end

    # Gastos operativos cuyos meses caen dentro del rango de fechas
    meses_en_rango = meses_entre(@fecha_desde.to_date, @fecha_hasta.to_date)
    meses_ids       = meses_en_rango.map { |y, m| y * 100 + m }

    # Nota: Los gastos operativos son generales, no se filtran por marca.
    # Esto significa que la Utilidad Neta al filtrar por marca será (Utilidad Bruta Marca - Gastos Totales),
    # lo cual puede ser negativo o engañoso, pero es lo matemáticamente correcto sin prorrateo.
    @gastos_operativos_total = if meses_ids.any?
      GastoOperativo
        .where("(periodo_year * 100 + periodo_mes) IN (?)", meses_ids)
        .sum(:gran_total_gastos).to_f
    else
      0.0
    end

    @utilidad_bruta   = (@ingresos_brutos - @cogs).round(2)
    @utilidad_neta    = (@utilidad_bruta - @gastos_operativos_total).round(2)
    @margen_neto_pct  = @ingresos_brutos > 0 ? ((@utilidad_neta / @ingresos_brutos) * 100).round(2) : 0.0
    @margen_bruto_pct = @ingresos_brutos > 0 ? ((@utilidad_bruta / @ingresos_brutos) * 100).round(2) : 0.0

    # ── Artículos vendidos ────────────────────────────────────────────────────
    if @marca_id.present?
      @total_articulos_vendidos = DetalleVenta.joins(:venta, :producto)
                                              .where(ventas: { fecha_venta: rango, finalizada: true }, productos: { marca_id: @marca_id })
                                              .sum(:cantidad).to_i
    else
      @total_articulos_vendidos = DetalleVenta.joins(:venta)
                                              .where(ventas: { fecha_venta: rango, finalizada: true })
                                              .sum(:cantidad).to_i
    end

    # ── Desglose gastos operativos para resumen ───────────────────────────────
    gastos_resumen = if meses_ids.any?
      GastoOperativo.where("(periodo_year * 100 + periodo_mes) IN (?)", meses_ids)
    else
      GastoOperativo.none
    end
    @gastos_alquiler       = gastos_resumen.sum(:costos_alquiler).to_f
    @gastos_utilidades     = gastos_resumen.sum(:costo_utilidades).to_f
    @gastos_mantenimiento  = gastos_resumen.sum(:costo_mantenimiento).to_f

    # ── Gráfico 1: Tendencia Ingresos vs COGS (dual-line) ───────────────────
    dias = (@fecha_hasta.to_date - @fecha_desde.to_date).to_i.clamp(0, 365)

    if @marca_id.present?
      ingresos_scope = DetalleVenta.joins(:venta, :producto)
                                   .where(ventas: { fecha_venta: rango, finalizada: true }, productos: { marca_id: @marca_id })
      cogs_scope     = DetalleVenta.joins(:venta, :producto)
                                   .where(ventas: { fecha_venta: rango, finalizada: true }, productos: { marca_id: @marca_id })
      
      ingresos_sum_col = "detalle_venta.cantidad * detalle_venta.precio_unitario_venta"
      cogs_sum_col     = "detalle_venta.cantidad * productos.costo_promedio_ponderado"
      date_col         = "ventas.fecha_venta"
    else
      ingresos_scope = Venta.finalizadas.where(fecha_venta: rango)
      cogs_scope     = DetalleVenta.joins(:venta, :producto).where(ventas: { fecha_venta: rango, finalizada: true })
      
      ingresos_sum_col = :cantidad_total
      cogs_sum_col     = "detalle_venta.cantidad * productos.costo_promedio_ponderado"
      date_col         = "fecha_venta" # Para Venta
      date_col_cogs    = "ventas.fecha_venta" # Para DetalleVenta
    end

    if dias <= 60
      if @marca_id.present?
        ingresos_raw = ingresos_scope
          .group("DATE(#{date_col} AT TIME ZONE 'UTC')")
          .sum(ingresos_sum_col)
          .transform_keys { |k| k.to_date }
      else
        ingresos_raw = ingresos_scope
          .group("DATE(#{date_col} AT TIME ZONE 'UTC')")
          .sum(ingresos_sum_col)
          .transform_keys { |k| k.to_date }
      end

      cogs_raw = cogs_scope
        .group("DATE(#{date_col_cogs || date_col} AT TIME ZONE 'UTC')")
        .sum(cogs_sum_col)
        .transform_keys { |k| k.to_date }

      @trend_labels    = (0..dias).map { |i| (@fecha_desde.to_date + i.days).strftime("%d/%m") }
      @trend_ingresos  = (0..dias).map { |i| ingresos_raw[(@fecha_desde.to_date + i.days)]&.to_f || 0 }
      @trend_costos    = (0..dias).map { |i| cogs_raw[(@fecha_desde.to_date + i.days)]&.to_f || 0 }
    else
      if @marca_id.present?
        ingresos_raw = ingresos_scope
          .group("DATE_TRUNC('week', #{date_col} AT TIME ZONE 'UTC')")
          .sum(ingresos_sum_col)
          .transform_keys { |k| k.to_date }
      else
        ingresos_raw = ingresos_scope
          .group("DATE_TRUNC('week', #{date_col} AT TIME ZONE 'UTC')")
          .sum(ingresos_sum_col)
          .transform_keys { |k| k.to_date }
      end

      cogs_raw = cogs_scope
        .group("DATE_TRUNC('week', #{date_col_cogs || date_col} AT TIME ZONE 'UTC')")
        .sum(cogs_sum_col)
        .transform_keys { |k| k.to_date }

      semanas = (ingresos_raw.keys + cogs_raw.keys).uniq.sort
      @trend_labels   = semanas.map { |d| "Sem #{d.strftime('%d/%m')}" }
      @trend_ingresos = semanas.map { |d| ingresos_raw[d]&.to_f || 0 }
      @trend_costos   = semanas.map { |d| cogs_raw[d]&.to_f || 0 }
    end

    # ── Gráfico 2: Método de pago ────────────────────────────────────────────
    if @marca_id.present?
      ventas_metodo = DetalleVenta.joins(:venta, :producto)
                                  .where(ventas: { fecha_venta: rango, finalizada: true }, productos: { marca_id: @marca_id })
                                  .group("ventas.metodo_pago")
                                  .sum("detalle_venta.cantidad * detalle_venta.precio_unitario_venta")
    else
      ventas_metodo = Venta.finalizadas.where(fecha_venta: rango).group(:metodo_pago).sum(:cantidad_total)
    end
    @metodo_pago_labels = ventas_metodo.keys.map { |k| Venta::METODOS_PAGO[k] || k }
    @metodo_pago_data   = ventas_metodo.values.map(&:to_f)

    # ── Gráfico 3: Utilidad por mes (bar) ────────────────────────────────────
    if @marca_id.present?
      ingresos_mes = DetalleVenta.joins(:venta, :producto)
                                 .where(ventas: { fecha_venta: rango, finalizada: true }, productos: { marca_id: @marca_id })
                                 .group("DATE_TRUNC('month', ventas.fecha_venta AT TIME ZONE 'UTC')")
                                 .sum("detalle_venta.cantidad * detalle_venta.precio_unitario_venta")
                                 .transform_keys { |k| k.to_date }
    else
      ingresos_mes = Venta.finalizadas
        .where(fecha_venta: rango)
        .group("DATE_TRUNC('month', fecha_venta AT TIME ZONE 'UTC')")
        .sum(:cantidad_total)
        .transform_keys { |k| k.to_date }
    end

    gastos_mes = if meses_ids.any?
      GastoOperativo
        .where("(periodo_year * 100 + periodo_mes) IN (?)", meses_ids)
        .index_by { |g| Date.new(g.periodo_year, g.periodo_mes, 1) }
    else
      {}
    end

    meses_trend = (ingresos_mes.keys + gastos_mes.keys).uniq.sort

    @util_mes_labels   = meses_trend.map { |d| d.strftime("%b %Y") }
    @util_mes_ingresos = meses_trend.map { |d| ingresos_mes[d]&.to_f || 0 }
    @util_mes_gastos   = meses_trend.map { |d| gastos_mes[d]&.gran_total_gastos&.to_f || 0 }
    @util_mes_data     = meses_trend.each_with_index.map { |d, i| @util_mes_ingresos[i] - @util_mes_gastos[i] }

    # ── Gráfico 4: Desglose gastos operativos (pie) ──────────────────────────
    gastos_records = if meses_ids.any?
      GastoOperativo.where("(periodo_year * 100 + periodo_mes) IN (?)", meses_ids)
    else
      GastoOperativo.none
    end
    @gastos_desglose_labels = [ "Alquiler", "Utilidades", "Mantenimiento" ]
    @gastos_desglose_data   = [
      gastos_records.sum(:costos_alquiler).to_f,
      gastos_records.sum(:costo_utilidades).to_f,
      gastos_records.sum(:costo_mantenimiento).to_f
    ]

    # ── Gráfico 5: Top 10 productos por ingreso (horizontal bar) ─────────────
    top_ingresos_scope = DetalleVenta.joins(:venta, :producto).where(ventas: { fecha_venta: rango, finalizada: true })
    top_ingresos_scope = top_ingresos_scope.where(productos: { marca_id: @marca_id }) if @marca_id.present?

    top_ingresos = top_ingresos_scope
      .group("productos.nombre")
      .sum("detalle_venta.cantidad * detalle_venta.precio_unitario_venta")
      .sort_by { |_, v| -v }
      .first(10)

    @top_ingresos_labels = top_ingresos.map(&:first)
    @top_ingresos_data   = top_ingresos.map { |_, v| v.to_f }

    # ── Gráfico 6: Top 10 productos por margen % (horizontal bar) ────────────
    top_margen_scope = DetalleVenta.joins(:venta, :producto).where(ventas: { fecha_venta: rango, finalizada: true })
    top_margen_scope = top_margen_scope.where(productos: { marca_id: @marca_id }) if @marca_id.present?

    top_margen_raw = top_margen_scope
      .group("productos.nombre", "productos.costo_promedio_ponderado")
      .select(
        "productos.nombre AS nombre",
        "productos.costo_promedio_ponderado AS cpp",
        "SUM(detalle_venta.cantidad * detalle_venta.precio_unitario_venta) AS total_ing",
        "SUM(detalle_venta.cantidad * productos.costo_promedio_ponderado) AS total_costo"
      )

    top_margen = top_margen_raw
      .map do |r|
        ingreso = r.total_ing.to_f
        costo   = r.total_costo.to_f
        margen  = ingreso > 0 ? ((ingreso - costo) / ingreso * 100).round(2) : 0.0
        [ r.nombre, margen ]
      end
      .sort_by { |_, m| -m }
      .first(10)

    @top_margen_labels = top_margen.map(&:first)
    @top_margen_data   = top_margen.map(&:last)

    # ── Tabla: Detalle de ventas ──────────────────────────────────────────────
    if @marca_id.present?
      @ventas_detalle = Venta.finalizadas
        .joins(detalle_ventas: :producto)
        .includes(:cliente, :detalle_ventas)
        .where(fecha_venta: rango, productos: { marca_id: @marca_id })
        .distinct
        .order(fecha_venta: :desc)
        .limit(50)
    else
      @ventas_detalle = Venta.finalizadas
        .includes(:cliente, :detalle_ventas)
        .where(fecha_venta: rango)
        .order(fecha_venta: :desc)
        .limit(50)
    end

    # ── Tabla: Desglose gastos operativos ────────────────────────────────────
    @gastos_detalle = if meses_ids.any?
      GastoOperativo
        .where("(periodo_year * 100 + periodo_mes) IN (?)", meses_ids)
        .order(:periodo_year, :periodo_mes)
    else
      GastoOperativo.none
    end

    # ── Tabla: Órdenes de compra ───────────────────────────────────────────
    if @marca_id.present?
      @compras_detalle = OrdenDeCompra.finalizadas
        .joins(detalle_ordenes_de_compra: :producto)
        .includes(:proveedor, :detalle_ordenes_de_compra)
        .where(fecha_compra: rango, productos: { marca_id: @marca_id })
        .distinct
        .order(fecha_compra: :desc)
        .limit(30)
    else
      @compras_detalle = OrdenDeCompra.finalizadas
        .includes(:proveedor, :detalle_ordenes_de_compra)
        .where(fecha_compra: rango)
        .order(fecha_compra: :desc)
        .limit(30)
    end
  end

  private

  def parse_date(str)
    return nil if str.blank?
    Date.parse(str).beginning_of_day
  rescue ArgumentError
    nil
  end

  def meses_entre(desde, hasta)
    meses = []
    current = Date.new(desde.year, desde.month, 1)
    fin     = Date.new(hasta.year, hasta.month, 1)
    while current <= fin
      meses << [ current.year, current.month ]
      current = current >> 1
    end
    meses
  end
end

