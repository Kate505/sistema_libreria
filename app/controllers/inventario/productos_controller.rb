class Inventario::ProductosController < ApplicationController
  before_action :set_producto, only: %i[edit update destroy]

  def index
    @producto = Producto.new
    @productos = Producto.includes(:categoria).all.order(:nombre)
  end

  def edit
    @producto = Producto.find_by(id: params[:id])
    @productos = Producto.includes(:categoria).all.order(:nombre)

    respond_to do |format|
      format.html { render :index }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "producto_form",
          partial: "inventario/productos/form",
          locals: { producto: @producto }
        )
      end
    end
  end

  def buscar_categoria
    @categorias = Categoria.where("nombre ILIKE ?", "%#{params[:q]}%")
                           .order(:nombre)
                           .limit(10)

    render json: @categorias.map { |c| { id: c.id, text: c.nombre } }
  end

  def create
    @producto = Producto.new(producto_params)

    if @producto.save
      @productos = Producto.includes(:categoria).all.order(:nombre)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("productos_table", partial: "inventario/productos/table", locals: { productos: @productos }),
            turbo_stream.replace("producto_form", partial: "inventario/productos/form", locals: { producto: Producto.new })
          ]
        end
        format.html { redirect_to inventario_productos_path, notice: "Producto creado exitosamente." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("producto_form", partial: "inventario/productos/form", locals: { producto: @producto })
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @producto.update(producto_params)
      @productos = Producto.includes(:categoria).all.order(:nombre)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("productos_table", partial: "inventario/productos/table", locals: { productos: @productos }),
            turbo_stream.replace("producto_form", partial: "inventario/productos/form", locals: { producto: Producto.new })
          ]
        end
        format.html { redirect_to inventario_productos_path, notice: "Producto actualizado exitosamente." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("producto_form", partial: "inventario/productos/form", locals: { producto: @producto })
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @producto.destroy
    @productos = Producto.includes(:categoria).all.order(:nombre)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("productos_table", partial: "inventario/productos/table", locals: { productos: @productos }),
          turbo_stream.replace("producto_form", partial: "inventario/productos/form", locals: { producto: Producto.new })
        ]
      end
      format.html { redirect_to inventario_productos_path, notice: "Producto eliminado exitosamente." }
    end
  end

  private

  def set_producto
    @producto = Producto.find(params[:id])
  end

  def producto_params
    params.require(:producto).permit(
      :categorias_id,
      :sku,
      :nombre,
      :descuento,
      :descuento_maximo,
      :stock_actual,
      :stock_minimo_limite,
      :stock_maximo_limite,
      :precio_venta,
      :precio_venta_al_mayor
    )
  end
end
