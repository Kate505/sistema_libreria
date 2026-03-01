class Facturacion::DetalleVentasController < ApplicationController
  before_action :set_venta
  before_action :set_detalle, only: %i[destroy]

  # POST /facturacion/ventas/:venta_id/detalle_ventas
  def create
    @detalle = @venta.detalle_ventas.new(detalle_params)

    if @detalle.save
      @detalles = detalles_recargados
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(
              "detalle_ventas_table",
              partial: "facturacion/detalle_ventas/table",
              locals: { venta: @venta, detalles: @detalles }
            ),
            turbo_stream.replace(
              "detalle_venta_form",
              partial: "facturacion/detalle_ventas/form",
              locals: { venta: @venta, detalle: DetalleVenta.new }
            ),
            turbo_stream.replace(
              "venta_resumen",
              partial: "facturacion/ventas/resumen",
              locals: { venta: @venta.reload }
            )
          ]
        end
        format.html { redirect_to facturacion_venta_path(@venta), notice: "Producto agregado exitosamente." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "detalle_venta_form",
            partial: "facturacion/detalle_ventas/form",
            locals: { venta: @venta, detalle: @detalle }
          )
        end
        format.html do
          @detalles = detalles_recargados
          render "facturacion/ventas/show", status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /facturacion/ventas/:venta_id/detalle_ventas/:id
  def destroy
    @detalle.destroy
    @detalles = detalles_recargados
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update(
            "detalle_ventas_table",
            partial: "facturacion/detalle_ventas/table",
            locals: { venta: @venta, detalles: @detalles }
          ),
          turbo_stream.replace(
            "detalle_venta_form",
            partial: "facturacion/detalle_ventas/form",
            locals: { venta: @venta, detalle: DetalleVenta.new }
          ),
          turbo_stream.replace(
            "venta_resumen",
            partial: "facturacion/ventas/resumen",
            locals: { venta: @venta.reload }
          )
        ]
      end
      format.html { redirect_to facturacion_venta_path(@venta), notice: "Línea eliminada y stock restaurado." }
    end
  end

  private

  def set_venta
    @venta = Venta.find(params[:venta_id])
  end

  def set_detalle
    @detalle = @venta.detalle_ventas.find(params[:id])
  end

  def detalles_recargados
    @venta.detalle_ventas.includes(:producto).order(:created_at)
  end

  def detalle_params
    params.require(:detalle_venta).permit(
      :producto_id,
      :cantidad,
      :precio_unitario_venta
    )
  end
end
