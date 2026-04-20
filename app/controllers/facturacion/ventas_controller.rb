class Facturacion::VentasController < ApplicationController
  before_action :set_venta, only: %i[show edit update destroy finalizar]

  # GET /facturacion/ventas
  def index
    @venta = Venta.new
    @ventas = Venta.includes(:cliente).where(metodo_pago: [nil, '']).order(fecha_venta: :desc)
  end

  # GET /facturacion/ventas/historial
  def historial
    @ventas = Venta.includes(:cliente).where.not(metodo_pago: [nil, ''])

    if params[:q].present?
      @ventas = @ventas.left_outer_joins(:cliente)
                       .where("ventas.id::text ILIKE :q OR clientes.primer_nombre ILIKE :q OR clientes.primer_apellido ILIKE :q", q: "%#{params[:q]}%")
    end

    if params[:metodo_pago].present?
      @ventas = @ventas.where(metodo_pago: params[:metodo_pago])
    end

    if params[:fecha_inicio].present? && params[:fecha_fin].present?
      @ventas = @ventas.where(fecha_venta: params[:fecha_inicio].to_date.beginning_of_day..params[:fecha_fin].to_date.end_of_day)
    end

    @ventas = @ventas.order(fecha_venta: :desc)
  end

  # GET /facturacion/ventas/:id
  def show
    @detalle = DetalleVenta.new
    @detalles = @venta.detalle_ventas
                      .includes(:producto)
                      .order(:created_at)
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
      redirect_to facturacion_venta_path(@venta), notice: "Venta iniciada exitosamente. Agregue los productos."
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
    if @venta.finalizada?
      redirect_to facturacion_venta_path(@venta), alert: "No se puede editar una venta finalizada."
      return
    end

    if @venta.update(venta_params)
      redirect_to facturacion_venta_path(@venta), notice: "Venta actualizada exitosamente."
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
    if @venta.finalizada?
      redirect_to facturacion_ventas_path, alert: "No se puede eliminar una venta finalizada."
      return
    end

    @venta.destroy
    redirect_to facturacion_ventas_path, notice: "Venta eliminada exitosamente."
  end

  # PATCH /facturacion/ventas/:id/finalizar
  def finalizar
    metodo = params[:metodo_pago]

    if @venta.detalle_ventas.empty?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "checkout_alert",
            html: '<div id="checkout_alert" class="alert alert-error text-sm py-2 mb-3"><span>Debe agregar al menos un producto antes de finalizar la venta.</span></div>'
          )
        end
        format.html { redirect_to facturacion_venta_path(@venta), alert: "Debe agregar al menos un producto antes de finalizar la venta." }
      end
      return
    end

    if metodo.blank? || !Venta::METODOS_PAGO.key?(metodo.strip.upcase)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "checkout_alert",
            html: '<div id="checkout_alert" class="alert alert-error text-sm py-2 mb-3"><span>Debe seleccionar un método de pago válido.</span></div>'
          )
        end
        format.html { redirect_to facturacion_venta_path(@venta), alert: "Método de pago inválido." }
      end
      return
    end

    @venta.metodo_pago = metodo.strip.upcase

    if @venta.save
      redirect_to facturacion_ventas_path, notice: "Venta ##{@venta.id} finalizada exitosamente."
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "checkout_alert",
            html: "<div id=\"checkout_alert\" class=\"alert alert-error text-sm py-2 mb-3\"><span>#{@venta.errors.full_messages.join(', ')}</span></div>"
          )
        end
        format.html { redirect_to facturacion_venta_path(@venta), alert: @venta.errors.full_messages.join(", ") }
      end
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

  private

  def set_venta
    @venta = Venta.find(params[:id])
  end

  def venta_params
    params.require(:venta).permit(:cliente_id, :fecha_venta)
  end
end
