class Facturacion::DetalleVentasController < ApplicationController
  before_action :set_venta
  before_action :set_detalle, only: %i[destroy]
  before_action :verificar_venta_abierta, only: %i[create destroy]

  # POST /facturacion/ventas/:venta_id/detalle_ventas
  def create
    @detalle = @venta.detalle_ventas.new(detalle_params)

    if @detalle.save
      @detalles = detalles_recargados
      flash.now[:notice] = "Producto agregado exitosamente."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(
              "detalle_ventas_table",
              partial: "facturacion/detalle_ventas/table",
              locals: { venta: @venta, detalles: @detalles }
            ),
            turbo_stream.replace(
              "detalle_venta_form_desktop",
              partial: "facturacion/detalle_ventas/form",
              locals: { venta: @venta, detalle: DetalleVenta.new, suffix: "desktop", saved: true }
            ),
            turbo_stream.replace(
              "detalle_venta_form_mobile",
              partial: "facturacion/detalle_ventas/form",
              locals: { venta: @venta, detalle: DetalleVenta.new, suffix: "mobile", saved: true }
            ),
            turbo_stream.replace(
              "venta_resumen",
              partial: "facturacion/ventas/resumen",
              locals: { venta: @venta.reload }
            ),
            turbo_stream.update(
              "flash-messages",
              partial: "shared/flash"
            )
          ]
        end
        format.html { redirect_to facturacion_venta_path(@venta), notice: "Producto agregado exitosamente." }
      end
    else
      flash.now[:alert] = "No se pudo agregar el producto."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "detalle_venta_form_desktop",
              partial: "facturacion/detalle_ventas/form",
              locals: { venta: @venta, detalle: @detalle, suffix: "desktop" }
            ),
            turbo_stream.replace(
              "detalle_venta_form_mobile",
              partial: "facturacion/detalle_ventas/form",
              locals: { venta: @venta, detalle: @detalle, suffix: "mobile" }
            ),
            turbo_stream.update(
              "flash-messages",
              partial: "shared/flash"
            )
          ]
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
    flash.now[:notice] = "Línea eliminada y stock restaurado."
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update(
            "detalle_ventas_table",
            partial: "facturacion/detalle_ventas/table",
            locals: { venta: @venta, detalles: @detalles }
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
          turbo_stream.replace(
            "venta_resumen",
            partial: "facturacion/ventas/resumen",
            locals: { venta: @venta.reload }
          ),
          turbo_stream.update(
            "flash-messages",
            partial: "shared/flash"
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
      :precio_unitario_venta,
      :descuento_porcentaje
    )
  end

  def verificar_venta_abierta
    return unless @venta.finalizada?

    flash.now[:alert] = "Esta venta ya fue finalizada y no admite cambios."
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
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
            "flash-messages",
            partial: "shared/flash"
          )
        ], status: :unprocessable_entity
      end
      format.html do
        redirect_to facturacion_venta_path(@venta),
                    alert: "Esta venta ya fue finalizada y no admite cambios."
      end
    end
  end
end
