class Facturacion::VentasController < ApplicationController

  before_action :set_venta, only: %i[show edit update destroy finalizar]
  before_action :verificar_venta_abierta, only: %i[update destroy]

  # GET /facturacion/ventas
  def index
    @venta = Venta.new
    @ventas = Venta.pendientes.includes(:cliente, :detalle_ventas).order(fecha_venta: :desc)
  end

  # GET /facturacion/ventas/:id
  def show
    @detalle = DetalleVenta.new
    @detalles = @venta.detalle_ventas
                      .includes(:producto)
                      .order(:created_at)
                      
    respond_to do |format|
      format.turbo_stream do
        # Switch inline del workspace al detalle de esta venta
        render turbo_stream: turbo_stream.replace(
          "ventas_workspace",
          partial: "facturacion/ventas/workspace_detalle",
          locals: { venta: @venta, detalle: @detalle, detalles: @detalles }
        )
      end
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
        @ventas = Venta.pendientes.includes(:cliente, :detalle_ventas).order(fecha_venta: :desc)
        render :index
      end
      format.turbo_stream do
        frame_id = request.headers["Turbo-Frame"].presence || "venta_form_desktop"
        suffix = frame_id.end_with?("_mobile") ? "mobile" : "desktop"
        render turbo_stream: turbo_stream.replace(
          frame_id,
          partial: "facturacion/ventas/form",
          locals: { venta: @venta, suffix: suffix }
        )
      end
    end
  end

  # POST /facturacion/ventas
  def create
    @venta = Venta.new(venta_params)
    @venta.user ||= Current.user

    if @venta.save
      @detalle = DetalleVenta.new
      @detalles = @venta.detalle_ventas.includes(:producto).order(:created_at)
      flash.now[:notice] = "Venta creada. Agrega los productos."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("ventas_workspace",
                                 partial: "facturacion/ventas/workspace_detalle",
                                 locals: { venta: @venta, detalle: @detalle, detalles: @detalles }),
            turbo_stream.update("flash-messages",
                                partial: "shared/flash")
          ]
        end
        format.html { redirect_to facturacion_venta_path(@venta), notice: "Venta creada." }
      end
    else
      flash.now[:alert] = "No se pudo crear la venta."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("venta_form_desktop",
                                 partial: "facturacion/ventas/form",
                                 locals: { venta: @venta, suffix: "desktop" }),
            turbo_stream.replace("venta_form_mobile",
                                 partial: "facturacion/ventas/form",
                                 locals: { venta: @venta, suffix: "mobile" }),
            turbo_stream.update("flash-messages",
                                partial: "shared/flash")
          ]
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /facturacion/ventas/:id
  def update
    if @venta.update(venta_params)
      @ventas = Venta.pendientes.includes(:cliente, :detalle_ventas).order(fecha_venta: :desc)
      flash.now[:notice] = "Venta actualizada exitosamente."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("ventas_table",
                                partial: "facturacion/ventas/table",
                                locals: { ventas: @ventas }),
            turbo_stream.replace("venta_form_desktop",
                                 partial: "facturacion/ventas/form",
                                 locals: { venta: Venta.new, suffix: "desktop" }),
            turbo_stream.replace("venta_form_mobile",
                                 partial: "facturacion/ventas/form",
                                 locals: { venta: Venta.new, suffix: "mobile", saved: true }),
            turbo_stream.update("flash-messages",
                                partial: "shared/flash")
          ]
        end
        format.html { redirect_to facturacion_ventas_path, notice: "Venta actualizada exitosamente." }
      end
    else
      flash.now[:alert] = "No se pudo actualizar la venta."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("venta_form_desktop",
                                 partial: "facturacion/ventas/form",
                                 locals: { venta: @venta, suffix: "desktop" }),
            turbo_stream.replace("venta_form_mobile",
                                 partial: "facturacion/ventas/form",
                                 locals: { venta: @venta, suffix: "mobile" }),
            turbo_stream.update("flash-messages",
                                partial: "shared/flash")
          ]
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /facturacion/ventas/:id
  def destroy
    @venta.destroy
    @ventas = Venta.pendientes.includes(:cliente, :detalle_ventas).order(fecha_venta: :desc)
    flash.now[:notice] = "Venta eliminada exitosamente."
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("ventas_table",
                              partial: "facturacion/ventas/table",
                              locals: { ventas: @ventas }),
          turbo_stream.replace("venta_form_desktop",
                               partial: "facturacion/ventas/form",
                               locals: { venta: Venta.new, suffix: "desktop" }),
          turbo_stream.replace("venta_form_mobile",
                               partial: "facturacion/ventas/form",
                               locals: { venta: Venta.new, suffix: "mobile" }),
          turbo_stream.update("flash-messages",
                              partial: "shared/flash")
        ]
      end
      format.html { redirect_to facturacion_ventas_path, notice: "Venta eliminada exitosamente." }
    end
  end

  # GET /facturacion/ventas/buscar_cliente?q=término
  def buscar_cliente
    @clientes = Cliente.where(
      "primer_nombre ILIKE :q OR primer_apellido ILIKE :q OR segundo_nombre ILIKE :q OR cedula ILIKE :q OR telefono ILIKE :q",
      q: "%#{params[:q]}%"
    ).order(:primer_apellido, :primer_nombre).limit(10)
    render json: @clientes.map { |c| { id: c.id, text: "#{c.primer_nombre} #{c.primer_apellido}" } }
  end

  # POST /facturacion/ventas/crear_cliente
  # Crea un cliente mínimo a partir de un texto libre (p.ej. "Juan Pérez").
  # Usado por el autocomplete cuando no se encuentran coincidencias.
  def crear_cliente
    nombre = params[:nombre].to_s.strip
    return render json: { error: "Nombre requerido" }, status: :unprocessable_entity if nombre.blank?

    attrs = parse_nombre_cliente(nombre)

    # Evitar duplicados obvios (mismo primer nombre + primer apellido)
    existente = Cliente.where("lower(primer_nombre) = ? AND lower(primer_apellido) = ?",
                              attrs[:primer_nombre].downcase,
                              attrs[:primer_apellido].downcase).first
    cliente = existente || Cliente.create!(attrs)

    render json: { id: cliente.id, text: "#{cliente.primer_nombre} #{cliente.primer_apellido}" }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
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
    @ventas = @ventas.page(params[:page]).per(10)
  end

  # GET /facturacion/ventas/buscar_producto?q=término
  def buscar_producto
    @productos = Producto.where(pasivo: false)
                         .where("nombre ILIKE :q OR sku ILIKE :q", q: "%#{params[:q]}%")
                         .where("stock_actual > 0")
                         .order(:nombre)
                         .limit(5)
    render json: @productos.map { |p|
      {
        id: p.id,
        text: "#{p.sku.presence || '—'} · #{p.nombre}",
        precio: p.precio_venta.to_s,
        precio_mayor: p.precio_venta_al_mayor.to_s,
        stock: p.stock_actual,
        descuento: p.descuento?,
        descuento_maximo: p.descuento_maximo.to_i
      }
    }
  end

  # PATCH /facturacion/ventas/:id/finalizar
  def finalizar
    metodo_pago   = params[:metodo_pago].to_s.strip.upcase
    moneda        = params[:moneda].to_s  # "NIO" o "USD"
    tasa_oficial  = ConfiguracionNegocio.configuracion.tasa_cambio
    tasa_cambio   = moneda == "USD" ? tasa_oficial : 0.to_d
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

      if vuelto < 0
        return respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "modal_finalizar",
              partial: "facturacion/ventas/modal_finalizar",
              locals: { venta: @venta, error: "El monto recibido en efectivo es insuficiente." }
            )
          end
        end
      end
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
              "detalle_venta_form_desktop",
              partial: "facturacion/detalle_ventas/form",
              locals: { venta: @venta, detalle: DetalleVenta.new, suffix: "desktop" }
            ),
            turbo_stream.replace(
              "detalle_venta_form_mobile",
              partial: "facturacion/detalle_ventas/form",
              locals: { venta: @venta, detalle: DetalleVenta.new, suffix: "mobile" }
            ),
            turbo_stream.update(
              "detalle_ventas_table",
              partial: "facturacion/detalle_ventas/table",
              locals: { venta: @venta, detalles: @detalles }
            ),
            # Mobile-specific: remove agregar btn + update payment status in header
            turbo_stream.remove("mobile_agregar_btn"),
            turbo_stream.replace(
              "venta_pago_status",
              html: "<span id=\"venta_pago_status\" class=\"font-medium\">#{Venta::METODOS_PAGO[@venta.metodo_pago] || @venta.metodo_pago}</span>"
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

  # GET /facturacion/ventas/volver_a_lista
  # Regresa el workspace al estado de lista (Estado A)
  def volver_a_lista
    @venta = Venta.new
    @ventas = Venta.pendientes.includes(:cliente, :detalle_ventas).order(fecha_venta: :desc)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "ventas_workspace",
          partial: "facturacion/ventas/workspace_lista",
          locals: { venta: @venta, ventas: @ventas }
        )
      end
      format.html { redirect_to facturacion_ventas_path }
    end
  end

  private

  # Heurística simple para separar nombres/apellidos en campos del modelo.
  # - 1 palabra: primer_nombre=palabra, primer_apellido="Sin apellido"
  # - 2 palabras: primer_nombre, primer_apellido
  # - 3 palabras: primer_nombre, primer_apellido, segundo_apellido
  # - 4+ palabras: primer_nombre, segundo_nombre, primer_apellido, segundo_apellido (resto)
  def parse_nombre_cliente(nombre)
    tokens = nombre.split(/\s+/).map(&:strip).reject(&:blank?)
    primer_nombre = tokens[0].to_s
    segundo_nombre = nil
    segundo_apellido = nil

    primer_apellido = case tokens.length
                     when 0
                       "Sin apellido"
                     when 1
                       "Sin apellido"
                     when 2
                       tokens[1]
                     when 3
                       segundo_apellido = tokens[2]
                       tokens[1]
                     else
                       segundo_nombre = tokens[1]
                       segundo_apellido = tokens[3..].join(" ")
                       tokens[2]
                     end

    {
      primer_nombre: primer_nombre.to_s.first(50),
      segundo_nombre: segundo_nombre.to_s.first(50).presence,
      primer_apellido: primer_apellido.to_s.first(50),
      segundo_apellido: segundo_apellido.to_s.first(50).presence
    }
  end

  def set_venta
    @venta = Venta.find(params[:id])
  end

  def venta_params
    params.require(:venta).permit(:cliente_id, :fecha_venta)
  end

  def verificar_venta_abierta
    return unless @venta.finalizada?

    flash.now[:alert] = "La Venta ##{@venta.id} ya fue finalizada y no se puede modificar."
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "venta_form_desktop",
            partial: "facturacion/ventas/form",
            locals: { venta: @venta, suffix: "desktop" }
          ),
          turbo_stream.replace(
            "venta_form_mobile",
            partial: "facturacion/ventas/form",
            locals: { venta: @venta, suffix: "mobile" }
          ),
          turbo_stream.update(
            "flash-messages",
            partial: "shared/flash"
          )
        ], status: :unprocessable_entity
      end
      format.html do
        redirect_to facturacion_ventas_path,
                    alert: "La Venta ##{@venta.id} ya fue finalizada y no se puede modificar."
      end
    end
  end
end
