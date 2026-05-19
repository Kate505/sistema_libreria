class Inventario::OrdenesDeCompraController < ApplicationController
  before_action :set_orden, only: %i[show edit update destroy finalizar]
  before_action :verificar_orden_abierta, only: %i[update destroy]

  # GET /inventario/ordenes_de_compra
  def index
    @orden_de_compra = OrdenDeCompra.new
    @ordenes_de_compra = OrdenDeCompra.includes(:proveedor)

    # Filtro por fecha desde
    if params[:fecha_desde].present?
      @ordenes_de_compra = @ordenes_de_compra.where("fecha_compra >= ?", params[:fecha_desde].to_date)
    end

    # Filtro por fecha hasta
    if params[:fecha_hasta].present?
      @ordenes_de_compra = @ordenes_de_compra.where("fecha_compra <= ?", params[:fecha_hasta].to_date)
    end

    @ordenes_de_compra = @ordenes_de_compra.order(fecha_compra: :desc, id: :desc)
                                           .page(params[:page]).per(10)
  end

  # GET /inventario/ordenes_de_compra/:id
  def show
    @detalle = DetalleOrdenDeCompra.new
    @detalles = @orden_de_compra.detalle_ordenes_de_compra
                                .includes(:producto)
                                .order(:created_at)
                                .page(params[:page]).per(8)
  end

  # GET /inventario/ordenes_de_compra/:id/edit
  def edit
    respond_to do |format|
      format.html do
        @ordenes_de_compra = OrdenDeCompra.includes(:proveedor).order(fecha_compra: :desc, id: :desc).page(1).per(15)
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
      @ordenes_de_compra = OrdenDeCompra.includes(:proveedor).order(fecha_compra: :desc, id: :desc).page(1).per(15)
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
      # Recalcular flete por si hubo un cambio en el costo total
      FreightCalculationService.call(@orden_de_compra)

      @ordenes_de_compra = OrdenDeCompra.includes(:proveedor).order(fecha_compra: :desc, id: :desc).page(1).per(15)
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
    @ordenes_de_compra = OrdenDeCompra.includes(:proveedor).order(fecha_compra: :desc, id: :desc).page(1).per(15)
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

  # PATCH /inventario/ordenes_de_compra/:id/finalizar
  def finalizar
    precios = params.dig(:precios_venta)&.permit!&.to_h || {}
    precios_mayor = params.dig(:precios_mayor)&.permit!&.to_h || {}
    if @orden_de_compra.finalizar!(precios: precios, precios_mayor: precios_mayor)
      @detalles = @orden_de_compra.detalle_ordenes_de_compra.includes(:producto).order(:created_at)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "modal_finalizar_orden",
              partial: "inventario/ordenes_de_compra/modal_finalizar",
              locals: { orden_de_compra: @orden_de_compra }
            ),
            turbo_stream.replace(
              "orden_de_compra_resumen",
              partial: "inventario/ordenes_de_compra/resumen",
              locals: { orden_de_compra: @orden_de_compra.reload }
            ),
            turbo_stream.replace(
              "detalle_orden_form",
              partial: "inventario/detalle_ordenes_de_compra/form",
              locals: { orden_de_compra: @orden_de_compra, detalle: DetalleOrdenDeCompra.new }
            ),
            turbo_stream.update(
              "detalle_ordenes_de_compra_table",
              partial: "inventario/detalle_ordenes_de_compra/table",
              locals: { orden_de_compra: @orden_de_compra, detalles: @detalles }
            )
          ]
        end
        format.html { redirect_to inventario_orden_de_compra_path(@orden_de_compra), notice: "Orden finalizada exitosamente." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal_finalizar_orden",
            partial: "inventario/ordenes_de_compra/modal_finalizar",
            locals: { orden_de_compra: @orden_de_compra, error: "La orden ya fue finalizada." }
          )
        end
        format.html { redirect_to inventario_orden_de_compra_path(@orden_de_compra), alert: "La orden ya fue finalizada." }
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal_finalizar_orden",
          partial: "inventario/ordenes_de_compra/modal_finalizar",
          locals: { orden_de_compra: @orden_de_compra, error: e.message }
        )
      end
      format.html { redirect_to inventario_orden_de_compra_path(@orden_de_compra), alert: e.message }
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
                         .limit(5)
    render json: @productos.map { |p| { id: p.id, text: "#{p.sku.presence || '—'} · #{p.nombre}" } }
  end

  # POST /inventario/ordenes_de_compra/crear_producto
  # Crea un producto mínimo desde el autocomplete
  def crear_producto
    nombre = params[:nombre].to_s.strip
    return render json: { error: "Nombre requerido" }, status: :unprocessable_entity if nombre.blank?

    categoria = Categoria.find_or_create_by!(nombre: 'Sin Categoría')
    existente = Producto.where("lower(nombre) = ?", nombre.downcase).first
    producto = existente || Producto.create!(nombre: nombre, categoria: categoria)

    render json: { id: producto.id, text: "#{producto.sku.presence || '—'} · #{producto.nombre}" }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
  end

  # POST /inventario/ordenes_de_compra/crear_proveedor
  # Crea un proveedor mínimo desde el autocomplete cuando no hay coincidencias.
  def crear_proveedor
    nombre = params[:nombre].to_s.strip
    return render json: { error: "Nombre requerido" }, status: :unprocessable_entity if nombre.blank?

    existente = Proveedor.where("lower(nombre) = ?", nombre.downcase).first
    proveedor = existente || Proveedor.create!(nombre: nombre)

    render json: { id: proveedor.id, text: proveedor.nombre }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
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

  def verificar_orden_abierta
    return unless @orden_de_compra.finalizada?

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "orden_de_compra_form",
          partial: "inventario/ordenes_de_compra/form",
          locals: { orden_de_compra: @orden_de_compra }
        ), status: :unprocessable_entity
      end
      format.html do
        redirect_to inventario_ordenes_de_compra_path,
                    alert: "La Orden ##{@orden_de_compra.id} ya fue finalizada y no se puede modificar."
      end
    end
  end
end
