class HomeController < ApplicationController
  def index
    @user = Current.user
    hoy   = Time.current

    # ── Parsear filtros de fecha ───────────────────────────────────────────
    @fecha_desde = parse_date(params[:fecha_desde]) || hoy.beginning_of_month
    @fecha_hasta = parse_date(params[:fecha_hasta]) || hoy.end_of_day
    # Asegurar que fecha_hasta cubra todo el día seleccionado
    @fecha_hasta = @fecha_hasta.end_of_day if @fecha_hasta.respond_to?(:end_of_day)
    @marca_id    = params[:marca_id]

    rango = @fecha_desde..@fecha_hasta

    # ── KPI Cards ─────────────────────────────────────────────────────────
    if @marca_id.present?
      @ventas_periodo = DetalleVenta.joins(:venta, :producto)
                                    .where(ventas: { fecha_venta: rango }, productos: { marca_id: @marca_id })
                                    .sum("detalle_venta.cantidad * detalle_venta.precio_unitario_venta")

      @total_ventas_count = Venta.joins(detalle_ventas: :producto)
                                 .where(fecha_venta: rango, productos: { marca_id: @marca_id })
                                 .distinct.count

      @ventas_hoy = DetalleVenta.joins(:venta, :producto)
                                .where(ventas: { fecha_venta: hoy.all_day }, productos: { marca_id: @marca_id })
                                .sum("detalle_venta.cantidad * detalle_venta.precio_unitario_venta")
    else
      @ventas_periodo     = Venta.where(fecha_venta: rango).sum(:cantidad_total)
      @total_ventas_count = Venta.where(fecha_venta: rango).count
      @ventas_hoy         = Venta.where(fecha_venta: hoy.all_day).sum(:cantidad_total)
    end

    productos_scope = Producto.all
    productos_scope = productos_scope.where(marca_id: @marca_id) if @marca_id.present?

    @valor_inventario     = productos_scope.sum("stock_actual * costo_promedio_ponderado")
    @productos_stock_bajo = productos_scope.where("stock_actual <= stock_minimo_limite").count
    @total_productos      = productos_scope.count

    # ── Gráfico 1: Tendencia de ventas en el período (línea) ─────────────
    dias = (@fecha_hasta.to_date - @fecha_desde.to_date).to_i.clamp(0, 365)
    
    # Base query for trend
    if @marca_id.present?
      trend_scope = DetalleVenta.joins(:venta, :producto)
                                .where(ventas: { fecha_venta: rango }, productos: { marca_id: @marca_id })
      sum_column = "detalle_venta.cantidad * detalle_venta.precio_unitario_venta"
      date_column = "ventas.fecha_venta"
    else
      trend_scope = Venta.where(fecha_venta: rango)
      sum_column = :cantidad_total
      date_column = "fecha_venta"
    end

    # Agrupar por día si ≤ 60 días, por semana si > 60
    if dias <= 60
      ventas_trend = trend_scope
        .group("DATE(#{date_column} AT TIME ZONE 'UTC')")
        .sum(sum_column)

      @trend_labels = (0..dias).map { |i| (@fecha_desde.to_date + i.days).strftime("%d/%m") }
      @trend_data   = (0..dias).map do |i|
        fecha = @fecha_desde.to_date + i.days
        ventas_trend[fecha]&.to_f || 0
      end
    else
      # Agrupar por semana
      ventas_trend = trend_scope
        .group("DATE_TRUNC('week', #{date_column} AT TIME ZONE 'UTC')")
        .sum(sum_column)
        .transform_keys { |k| k.to_date }

      semanas = ventas_trend.keys.sort
      @trend_labels = semanas.map { |d| "Sem #{d.strftime('%d/%m')}" }
      @trend_data   = semanas.map { |d| ventas_trend[d]&.to_f || 0 }
    end

    # ── Gráfico 2: Top 5 productos más vendidos (barras horizontales) ────
    top_productos_scope = DetalleVenta.joins(:venta, :producto).where(ventas: { fecha_venta: rango })
    top_productos_scope = top_productos_scope.where(productos: { marca_id: @marca_id }) if @marca_id.present?

    top_productos = top_productos_scope
      .group("productos.nombre")
      .sum(:cantidad)
      .sort_by { |_, v| -v }
      .first(5)

    @top_productos_labels = top_productos.map(&:first)
    @top_productos_data   = top_productos.map(&:last)

    # ── Gráfico 3: Ventas por método de pago (doughnut) ──────────────────
    # Nota: Si se filtra por marca, mostramos los métodos de pago de las ventas que contienen esa marca.
    # El monto será el total de la venta (limitación conocida) o podríamos intentar sumar solo los detalles.
    # Para consistencia con "Ingresos", sumaremos solo los detalles de esa marca por método de pago.
    
    if @marca_id.present?
      ventas_metodo = DetalleVenta.joins(:venta, :producto)
                                  .where(ventas: { fecha_venta: rango }, productos: { marca_id: @marca_id })
                                  .group("ventas.metodo_pago")
                                  .sum("detalle_venta.cantidad * detalle_venta.precio_unitario_venta")
    else
      ventas_metodo = Venta.where(fecha_venta: rango).group(:metodo_pago).sum(:cantidad_total)
    end

    @metodo_pago_labels = ventas_metodo.keys.map { |k| Venta::METODOS_PAGO[k] || k }
    @metodo_pago_data   = ventas_metodo.values.map(&:to_f)

    # ── Gráfico 4: Ventas por categoría (barras) — NUEVO ─────────────────
    ventas_cat_scope = DetalleVenta.joins(:venta, producto: :categoria).where(ventas: { fecha_venta: rango })
    ventas_cat_scope = ventas_cat_scope.where(productos: { marca_id: @marca_id }) if @marca_id.present?

    ventas_cat = ventas_cat_scope
      .group("categorias.nombre")
      .sum("detalle_venta.cantidad * detalle_venta.precio_unitario_venta")
      .sort_by { |_, v| -v }

    @ventas_cat_labels = ventas_cat.map(&:first)
    @ventas_cat_data   = ventas_cat.map { |_, v| v.to_f }

    # ── Gráfico 5: Stock actual por categoría (barras) ────────────────────
    stock_cat_scope = Producto.joins(:categoria)
    stock_cat_scope = stock_cat_scope.where(marca_id: @marca_id) if @marca_id.present?

    stock_cat = stock_cat_scope
      .group("categorias.nombre")
      .sum(:stock_actual)

    @stock_cat_labels = stock_cat.keys
    @stock_cat_data   = stock_cat.values.map(&:to_i)

    # ── Tabla: Productos con stock bajo ───────────────────────────────────
    @productos_bajo_stock = productos_scope
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
