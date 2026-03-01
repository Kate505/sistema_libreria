class Inventario::DetalleOrdenesDeCompraController < ApplicationController
  before_action :set_orden
  before_action :set_detalle, only: %i[destroy]

  # POST /inventario/ordenes_de_compra/:orden_de_compra_id/detalle_ordenes_de_compra
  def create
    @detalle = @orden_de_compra.detalle_ordenes_de_compra.new(detalle_params)

    if @detalle.save
      @detalles = detalles_recargados
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(
              "detalle_ordenes_de_compra_table",
              partial: "inventario/detalle_ordenes_de_compra/table",
              locals: { orden_de_compra: @orden_de_compra, detalles: @detalles }
            ),
            turbo_stream.replace(
              "detalle_orden_form",
              partial: "inventario/detalle_ordenes_de_compra/form",
              locals: { orden_de_compra: @orden_de_compra, detalle: DetalleOrdenDeCompra.new }
            ),
            turbo_stream.replace(
              "orden_de_compra_resumen",
              partial: "inventario/ordenes_de_compra/resumen",
              locals: { orden_de_compra: @orden_de_compra.reload }
            )
          ]
        end
        format.html { redirect_to inventario_orden_de_compra_path(@orden_de_compra), notice: "Producto agregado exitosamente." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "detalle_orden_form",
            partial: "inventario/detalle_ordenes_de_compra/form",
            locals: { orden_de_compra: @orden_de_compra, detalle: @detalle }
          )
        end
        format.html do
          @detalles = detalles_recargados
          render "inventario/ordenes_de_compra/show", status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /inventario/ordenes_de_compra/:orden_de_compra_id/detalle_ordenes_de_compra/:id
  def destroy
    @detalle.destroy
    @detalles = detalles_recargados
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update(
            "detalle_ordenes_de_compra_table",
            partial: "inventario/detalle_ordenes_de_compra/table",
            locals: { orden_de_compra: @orden_de_compra, detalles: @detalles }
          ),
          turbo_stream.replace(
            "detalle_orden_form",
            partial: "inventario/detalle_ordenes_de_compra/form",
            locals: { orden_de_compra: @orden_de_compra, detalle: DetalleOrdenDeCompra.new }
          ),
          turbo_stream.replace(
            "orden_de_compra_resumen",
            partial: "inventario/ordenes_de_compra/resumen",
            locals: { orden_de_compra: @orden_de_compra.reload }
          )
        ]
      end
      format.html { redirect_to inventario_orden_de_compra_path(@orden_de_compra), notice: "Línea eliminada y stock revertido." }
    end
  end

  private

  def set_orden
    @orden_de_compra = OrdenDeCompra.find(params[:orden_de_compra_id])
  end

  def set_detalle
    @detalle = @orden_de_compra.detalle_ordenes_de_compra.find(params[:id])
  end

  def detalles_recargados
    @orden_de_compra.detalle_ordenes_de_compra.includes(:producto).order(:created_at)
  end

  def detalle_params
    params.require(:detalle_orden_de_compra).permit(
      :producto_id,
      :cantidad,
      :precio_unitario_compra,
      :costo_unitario_compra_calculado
    )
  end
end
