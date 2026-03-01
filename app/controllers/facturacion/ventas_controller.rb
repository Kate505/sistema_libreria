class Facturacion::VentasController < ApplicationController
  before_action :set_venta, only: %i[show edit update destroy]

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
    params.require(:venta).permit(:cliente_id, :fecha_venta, :metodo_pago)
  end
end
