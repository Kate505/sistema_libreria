class Inventario::OrdenesDeCompraController < ApplicationController
  before_action :set_orden, only: %i[show edit update destroy]

  # GET /inventario/ordenes_de_compra
  def index
    @orden_de_compra = OrdenDeCompra.new
    @ordenes_de_compra = OrdenDeCompra.includes(:proveedor)
                                      .order(fecha_compra: :desc)
  end

  # GET /inventario/ordenes_de_compra/:id
  def show
    @detalle = DetalleOrdenDeCompra.new
    @detalles = @orden_de_compra.detalle_ordenes_de_compra
                                .includes(:producto)
                                .order(:created_at)
  end

  # GET /inventario/ordenes_de_compra/:id/edit
  def edit
    respond_to do |format|
      format.html do
        @ordenes_de_compra = OrdenDeCompra.includes(:proveedor).order(fecha_compra: :desc)
        render :index
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "orden_de_compra_form",
          partial: "inventario/ordenes_de_compra/form",
          locals: { orden_de_compra: @orden_de_compra }
        )
      end
    end
  end

  # POST /inventario/ordenes_de_compra
  def create
    @orden_de_compra = OrdenDeCompra.new(orden_params)

    if @orden_de_compra.save
      @ordenes_de_compra = OrdenDeCompra.includes(:proveedor).order(fecha_compra: :desc)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("ordenes_de_compra_table",
                                partial: "inventario/ordenes_de_compra/table",
                                locals: { ordenes_de_compra: @ordenes_de_compra }),
            turbo_stream.replace("orden_de_compra_form",
                                 partial: "inventario/ordenes_de_compra/form",
                                 locals: { orden_de_compra: OrdenDeCompra.new })
          ]
        end
        format.html { redirect_to inventario_ordenes_de_compra_path, notice: "Orden de compra creada exitosamente." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "orden_de_compra_form",
            partial: "inventario/ordenes_de_compra/form",
            locals: { orden_de_compra: @orden_de_compra }
          )
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /inventario/ordenes_de_compra/:id
  def update
    if @orden_de_compra.update(orden_params)
      @ordenes_de_compra = OrdenDeCompra.includes(:proveedor).order(fecha_compra: :desc)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("ordenes_de_compra_table",
                                partial: "inventario/ordenes_de_compra/table",
                                locals: { ordenes_de_compra: @ordenes_de_compra }),
            turbo_stream.replace("orden_de_compra_form",
                                 partial: "inventario/ordenes_de_compra/form",
                                 locals: { orden_de_compra: OrdenDeCompra.new })
          ]
        end
        format.html { redirect_to inventario_ordenes_de_compra_path, notice: "Orden de compra actualizada exitosamente." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "orden_de_compra_form",
            partial: "inventario/ordenes_de_compra/form",
            locals: { orden_de_compra: @orden_de_compra }
          )
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inventario/ordenes_de_compra/:id
  def destroy
    @orden_de_compra.destroy
    @ordenes_de_compra = OrdenDeCompra.includes(:proveedor).order(fecha_compra: :desc)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("ordenes_de_compra_table",
                              partial: "inventario/ordenes_de_compra/table",
                              locals: { ordenes_de_compra: @ordenes_de_compra }),
          turbo_stream.replace("orden_de_compra_form",
                               partial: "inventario/ordenes_de_compra/form",
                               locals: { orden_de_compra: OrdenDeCompra.new })
        ]
      end
      format.html { redirect_to inventario_ordenes_de_compra_path, notice: "Orden de compra eliminada exitosamente." }
    end
  end

  # GET /inventario/ordenes_de_compra/buscar_proveedor?q=término
  def buscar_proveedor
    @proveedores = Proveedor.where("nombre ILIKE ?", "%#{params[:q]}%")
                            .order(:nombre)
                            .limit(10)
    render json: @proveedores.map { |p| { id: p.id, text: p.nombre } }
  end

  # GET /inventario/ordenes_de_compra/buscar_producto?q=término
  def buscar_producto
    @productos = Producto.where("nombre ILIKE :q OR sku ILIKE :q", q: "%#{params[:q]}%")
                         .order(:nombre)
                         .limit(10)
    render json: @productos.map { |p| { id: p.id, text: "#{p.sku.presence || '—'} · #{p.nombre}" } }
  end

  private

  def set_orden
    @orden_de_compra = OrdenDeCompra.find(params[:id])
  end

  def orden_params
    params.require(:orden_de_compra).permit(
      :proveedor_id,
      :fecha_compra,
      :numero_factura,
      :costo_total_flete
    )
  end
end
