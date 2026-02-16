class Inventario::ProductosController < ApplicationController

  def index
    @producto = Producto.new
    @productos = Producto.all.order(:nombre)
  end

  def edit
    @producto = Producto.find_by(id: params[:id])
    render partial: "form", locals: { producto: @producto }
  end

  def create
    @producto = Producto.new(producto_params)
    if @producto.save
      @productos = Producto.all.order(:nombre)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("productos_table", partial: "inventario/productos/table", locals: { productos: @productos }),

            turbo_stream.replace("producto_form", partial: "inventario/productos/form", locals: { producto: Producto.new })
          ]
        end

        format.html { redirect_to inventario_productos_path, notice: "Creado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("producto_form", partial: "inventario/productos/form", locals: { producto: @producto }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @producto.update(producto_params)
      @productos = Producto.all.order(:nombre)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("productos_table", partial: "inventario/productos/table", locals: { productos: @productos }),
            turbo_stream.replace("producto_form", partial: "inventario/productos/form", locals: { producto: Producto.new })
          ]
        end
        format.html { redirect_to inventario_productos_path, notice: "Actualizado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("producto_form", partial: "inventario/productos/form", locals: { producto: @producto }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @producto.destroy
    @productos = Producto.all.order(:nombre)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("producto_#{@producto.id}")
      end
      format.html { redirect_to inventario_productos_path, notice: "Eliminado" }
    end
  end

  private

  def set_producto
    @producto = Producto.find(params[:id])
  end

  # TODO: Agregarle el campo Pasivo a la tabla Productos
  def producto_params
    params.require(:producto).permit(:categoria_id, :sku, :nombre, :descuento, :descuento_maximo,
                                     :stock_actual, :stock_minimo_limite, :stock_maximo_limite,
                                     :costo_promedio_ponderado, :ultimo_precio_compra, :precio_venta,
                                     :precio_venta_al_mayor)
  end

end
