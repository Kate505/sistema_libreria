class HomeController < ApplicationController
  def index
    @user = Current.user
    hoy   = Time.current

    # ── Parsear filtros de fecha ───────────────────────────────────────────
    @fecha_desde = parse_date(params[:fecha_desde]) || hoy.beginning_of_month
    @fecha_hasta = parse_date(params[:fecha_hasta]) || hoy.end_of_day
    # Asegurar que fecha_hasta cubra todo el día seleccionado
    @fecha_hasta = @fecha_hasta.end_of_day if @fecha_hasta.respond_to?(:end_of_day)

    rango = @fecha_desde..@fecha_hasta

    # ── KPI Cards ─────────────────────────────────────────────────────────
    @ventas_periodo       = Venta.where(fecha_venta: rango).sum(:cantidad_total)
    @total_ventas_count   = Venta.where(fecha_venta: rango).count
    @ventas_hoy           = Venta.where(fecha_venta: hoy.all_day).sum(:cantidad_total)
    @valor_inventario     = Producto.sum("stock_actual * costo_promedio_ponderado")
    @productos_stock_bajo = Producto.where("stock_actual <= stock_minimo_limite").count
    @total_productos      = Producto.count

    # ── Gráfico 1: Tendencia de ventas en el período (línea) ─────────────
    dias = (@fecha_hasta.to_date - @fecha_desde.to_date).to_i.clamp(0, 365)
    # Agrupar por día si ≤ 60 días, por semana si > 60
    if dias <= 60
      ventas_trend = Venta
        .where(fecha_venta: rango)
        .group("DATE(fecha_venta AT TIME ZONE 'UTC')")
        .sum(:cantidad_total)

      @trend_labels = (0..dias).map { |i| (@fecha_desde.to_date + i.days).strftime("%d/%m") }
      @trend_data   = (0..dias).map do |i|
        fecha = @fecha_desde.to_date + i.days
        ventas_trend[fecha]&.to_f || 0
      end
    else
      # Agrupar por semana
      ventas_trend = Venta
        .where(fecha_venta: rango)
        .group("DATE_TRUNC('week', fecha_venta AT TIME ZONE 'UTC')")
        .sum(:cantidad_total)
        .transform_keys { |k| k.to_date }

      semanas = ventas_trend.keys.sort
      @trend_labels = semanas.map { |d| "Sem #{d.strftime('%d/%m')}" }
      @trend_data   = semanas.map { |d| ventas_trend[d]&.to_f || 0 }
    end

    # ── Gráfico 2: Top 5 productos más vendidos (barras horizontales) ────
    top_productos = DetalleVenta
      .joins(:venta, :producto)
      .where(ventas: { fecha_venta: rango })
      .group("productos.nombre")
      .sum(:cantidad)
      .sort_by { |_, v| -v }
      .first(5)

    @top_productos_labels = top_productos.map(&:first)
    @top_productos_data   = top_productos.map(&:last)

    # ── Gráfico 3: Ventas por método de pago (doughnut) ──────────────────
    ventas_metodo = Venta.where(fecha_venta: rango).group(:metodo_pago).sum(:cantidad_total)
    @metodo_pago_labels = ventas_metodo.keys.map { |k| Venta::METODOS_PAGO[k] || k }
    @metodo_pago_data   = ventas_metodo.values.map(&:to_f)

    # ── Gráfico 4: Ventas por categoría (barras) — NUEVO ─────────────────
    ventas_cat = DetalleVenta
      .joins(:venta, producto: :categoria)
      .where(ventas: { fecha_venta: rango })
      .group("categorias.nombre")
      .sum("detalle_venta.cantidad * detalle_venta.precio_unitario_venta")
      .sort_by { |_, v| -v }

    @ventas_cat_labels = ventas_cat.map(&:first)
    @ventas_cat_data   = ventas_cat.map { |_, v| v.to_f }

    # ── Gráfico 5: Stock actual por categoría (barras) ────────────────────
    stock_cat = Producto
      .joins(:categoria)
      .group("categorias.nombre")
      .sum(:stock_actual)

    @stock_cat_labels = stock_cat.keys
    @stock_cat_data   = stock_cat.values.map(&:to_i)

    # ── Tabla: Productos con stock bajo ───────────────────────────────────
    @productos_bajo_stock = Producto
      .includes(:categoria)
      .where("stock_actual <= stock_minimo_limite")
      .order(stock_actual: :asc)
      .limit(8)
  end

  private

  def parse_date(str)
    return nil if str.blank?

    Date.parse(str).beginning_of_day
  rescue ArgumentError
    nil
  end
end
