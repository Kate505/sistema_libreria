class Facturacion::VentasController < ApplicationController
  before_action :set_venta, only: %i[show edit update destroy finalizar]
  before_action :verificar_venta_abierta, only: %i[update destroy]

  # GET /facturacion/ventas
  def index
    @venta = Venta.new
    @ventas = Venta.includes(:cliente).order(fecha_venta: :desc)
  end

  # GET /facturacion/ventas/:id
  def show
    @detalle = DetalleVenta.new
    @detalles = @venta.detalle_ventas
                      .includes(:producto)
                      .order(:created_at)
                      
    respond_to do |format|
      format.html do
        # Si el detalle se solicita desde el historial, lo devolvemos como modal
        # (sin navegar a la pantalla de ventas).
        if turbo_frame_request? && request.headers["Turbo-Frame"].to_s == "venta_detalle_modal"
          render partial: "historial_detalle_modal",
                 locals: { venta: @venta, detalles: @detalles },
                 layout: false
        else
          render :show
        end
      end
      format.pdf do
        pdf = Pdf::FacturaVenta.new(@venta)
        send_data pdf.render,
                  filename: "factura_venta_#{@venta.id}.pdf",
                  type: "application/pdf",
                  disposition: "inline" # 'inline' abre en el navegador, 'attachment' descarga
      end
    end
  end

  # GET /facturacion/ventas/:id/edit
  def edit
    respond_to do |format|
      format.html do
        @ventas = Venta.includes(:cliente).order(fecha_venta: :desc)
        render :index
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "venta_form",
          partial: "facturacion/ventas/form",
          locals: { venta: @venta }
        )
      end
    end
  end

  # POST /facturacion/ventas
  def create
    @venta = Venta.new(venta_params)

    if @venta.save
      @ventas = Venta.includes(:cliente).order(fecha_venta: :desc)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("ventas_table",
                                partial: "facturacion/ventas/table",
                                locals: { ventas: @ventas }),
            turbo_stream.replace("venta_form",
                                 partial: "facturacion/ventas/form",
                                 locals: { venta: Venta.new })
          ]
        end
        format.html { redirect_to facturacion_ventas_path, notice: "Venta creada exitosamente." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "venta_form",
            partial: "facturacion/ventas/form",
            locals: { venta: @venta }
          )
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /facturacion/ventas/:id
  def update
    if @venta.update(venta_params)
      @ventas = Venta.includes(:cliente).order(fecha_venta: :desc)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("ventas_table",
                                partial: "facturacion/ventas/table",
                                locals: { ventas: @ventas }),
            turbo_stream.replace("venta_form",
                                 partial: "facturacion/ventas/form",
                                 locals: { venta: Venta.new })
          ]
        end
        format.html { redirect_to facturacion_ventas_path, notice: "Venta actualizada exitosamente." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "venta_form",
            partial: "facturacion/ventas/form",
            locals: { venta: @venta }
          )
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /facturacion/ventas/:id
  def destroy
    @venta.destroy
    @ventas = Venta.includes(:cliente).order(fecha_venta: :desc)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("ventas_table",
                              partial: "facturacion/ventas/table",
                              locals: { ventas: @ventas }),
          turbo_stream.replace("venta_form",
                               partial: "facturacion/ventas/form",
                               locals: { venta: Venta.new })
        ]
      end
      format.html { redirect_to facturacion_ventas_path, notice: "Venta eliminada exitosamente." }
    end
  end

  # GET /facturacion/ventas/buscar_cliente?q=término
  def buscar_cliente
    @clientes = Cliente.where(
      "primer_nombre ILIKE :q OR primer_apellido ILIKE :q OR segundo_nombre ILIKE :q",
      q: "%#{params[:q]}%"
    ).order(:primer_apellido, :primer_nombre).limit(10)
    render json: @clientes.map { |c| { id: c.id, text: "#{c.primer_nombre} #{c.primer_apellido}" } }
  end

  # GET /facturacion/ventas/historial
  def historial
    # Defaults: al entrar sin parámetros, mostrar únicamente ventas finalizadas del día actual.
    # Se hace vía redirect para que los inputs del formulario queden precargados con los valores.
    if request.get? && request.query_parameters.blank?
      hoy = Date.current
      return redirect_to historial_facturacion_ventas_path(
        fecha_desde: hoy.iso8601,
        fecha_hasta: hoy.iso8601,
        estado: "finalizada"
      )
    end

    @ventas = Venta.includes(:cliente, :detalle_ventas)
                   .order(fecha_venta: :desc)

    # Filtro por fecha desde
    if params[:fecha_desde].present?
      @ventas = @ventas.where("fecha_venta >= ?", params[:fecha_desde].to_date.beginning_of_day)
    end

    # Filtro por fecha hasta
    if params[:fecha_hasta].present?
      @ventas = @ventas.where("fecha_venta <= ?", params[:fecha_hasta].to_date.end_of_day)
    end

    # Filtro por nombre del cliente
    if params[:cliente_nombre].present?
      q = "%#{params[:cliente_nombre]}%"
      @ventas = @ventas.joins(:cliente)
                       .where("clientes.primer_nombre ILIKE :q OR clientes.primer_apellido ILIKE :q OR clientes.segundo_nombre ILIKE :q", q: q)
    end

    # Filtro por método de pago
    if params[:metodo_pago].present?
      @ventas = @ventas.where(metodo_pago: params[:metodo_pago])
    end

    # Filtro por estado
    if params[:estado].present?
      @ventas = params[:estado] == "finalizada" ? @ventas.finalizadas : @ventas.pendientes
    end

    @total_general = @ventas.sum(:cantidad_total)
    @total_ventas  = @ventas.count
  end

  # GET /facturacion/ventas/buscar_producto?q=término
  def buscar_producto
    @productos = Producto.where("nombre ILIKE :q OR sku ILIKE :q", q: "%#{params[:q]}%")
                         .where("stock_actual > 0")
                         .order(:nombre)
                         .limit(10)
    render json: @productos.map { |p|
      {
        id: p.id,
        text: "#{p.sku.presence || '—'} · #{p.nombre}",
        precio: p.precio_venta.to_s,
        stock: p.stock_actual
      }
    }
  end

  # PATCH /facturacion/ventas/:id/finalizar
  def finalizar
    metodo_pago   = params[:metodo_pago].to_s.strip.upcase
    moneda        = params[:moneda].to_s  # "NIO" o "USD"
    tasa_cambio   = params[:tasa_cambio].to_d
    monto_recibido = params[:monto_recibido].to_d

    unless Venta::METODOS_PAGO.key?(metodo_pago)
      return respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal_finalizar",
            partial: "facturacion/ventas/modal_finalizar",
            locals: { venta: @venta, error: "Selecciona un método de pago válido." }
          )
        end
      end
    end

    # Calcular vuelto si es efectivo
    vuelto = nil
    if metodo_pago == "E"
      total_nios = @venta.cantidad_total.to_d
      if moneda == "USD" && tasa_cambio > 0
        monto_recibido_nios = monto_recibido * tasa_cambio
      else
        monto_recibido_nios = monto_recibido
      end
      vuelto = monto_recibido_nios - total_nios
    end

    if @venta.update(metodo_pago: metodo_pago, finalizada: true)
      @detalles = @venta.detalle_ventas.includes(:producto).order(:created_at)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "modal_finalizar",
              partial: "facturacion/ventas/modal_resultado",
              locals: {
                venta: @venta,
                vuelto: vuelto,
                moneda: moneda,
                tasa_cambio: tasa_cambio,
                monto_recibido: monto_recibido
              }
            ),
            turbo_stream.replace(
              "venta_resumen",
              partial: "facturacion/ventas/resumen",
              locals: { venta: @venta.reload }
            ),
            turbo_stream.replace(
              "detalle_venta_form",
              partial: "facturacion/detalle_ventas/form",
              locals: { venta: @venta, detalle: DetalleVenta.new }
            ),
            turbo_stream.update(
              "detalle_ventas_table",
              partial: "facturacion/detalle_ventas/table",
              locals: { venta: @venta, detalles: @detalles }
            )
          ]
        end
        format.html { redirect_to facturacion_venta_path(@venta), notice: "Venta finalizada exitosamente." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal_finalizar",
            partial: "facturacion/ventas/modal_finalizar",
            locals: { venta: @venta, error: @venta.errors.full_messages.to_sentence }
          )
        end
        format.html { redirect_to facturacion_venta_path(@venta), alert: @venta.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def set_venta
    @venta = Venta.find(params[:id])
  end

  def venta_params
    params.require(:venta).permit(:cliente_id, :fecha_venta)
  end

  def verificar_venta_abierta
    return unless @venta.finalizada?

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "venta_form",
          partial: "facturacion/ventas/form",
          locals: { venta: @venta }
        ), status: :unprocessable_entity
      end
      format.html do
        redirect_to facturacion_ventas_path,
                    alert: "La Venta ##{@venta.id} ya fue finalizada y no se puede modificar."
      end
    end
  end
end
