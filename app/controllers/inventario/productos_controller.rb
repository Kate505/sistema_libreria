class Inventario::ProductosController < ApplicationController
  before_action :set_producto, only: %i[edit update destroy]

  def index
    @producto = Producto.new
    @productos = Producto.includes(:categoria, :marca).all.order(:nombre)

    if params[:q].present?
      @productos = @productos.left_joins(:categoria).where(
        "productos.nombre ILIKE :q OR productos.sku ILIKE :q OR categorias.nombre ILIKE :q",
        q: "%#{params[:q]}%"
      )
    end

    @productos = @productos.page(params[:page]).per(10)
  end

  def edit
    @producto = Producto.find_by(id: params[:id])
    @productos = Producto.includes(:categoria, :marca).all.order(:nombre).page(params[:page]).per(10)

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

  def buscar_marca
    term = params[:q].to_s.strip

    @marcas = Marca.order(:nombre)
    @marcas = @marcas.where("nombre ILIKE ?", "%#{term}%") unless term.blank?
    @marcas = @marcas.limit(10)

    render json: @marcas.map { |m| { id: m.id, text: m.nombre } }
  end

  # POST /inventario/productos/crear_categoria
  def crear_categoria
    nombre = params[:nombre].to_s.strip
    return render json: { error: "Nombre requerido" }, status: :unprocessable_entity if nombre.blank?

    categoria = Categoria.find_or_initialize_by(nombre: nombre)
    if categoria.new_record?
      categoria.save!
    end

    render json: { id: categoria.id, text: categoria.nombre }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
  end

  # POST /inventario/productos/crear_marca
  def crear_marca
    nombre = params[:nombre].to_s.strip
    return render json: { error: "Nombre requerido" }, status: :unprocessable_entity if nombre.blank?

    marca = Marca.find_or_initialize_by(nombre: nombre)
    if marca.new_record?
      marca.save!
    end

    render json: { id: marca.id, text: marca.nombre }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
  end

  def consulta_precios
    @q = params[:q].to_s.strip
    @productos = Producto.preload(:categoria)
                         .order(:nombre, :id)
    unless @q.blank?
      @productos = @productos.left_joins(:categoria).where(
        "productos.nombre ILIKE :term OR productos.sku ILIKE :term OR categorias.nombre ILIKE :term",
        term: "%#{@q}%"
      )
    end

    @productos = @productos.page(params[:page]).per(10)
  end

  def create
    @producto = Producto.new(producto_params)

    if @producto.save
      @productos = Producto.includes(:categoria, :marca).all.order(:nombre).page(1).per(10)
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
      @productos = Producto.includes(:categoria, :marca).all.order(:nombre).page(1).per(10)
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
    @productos = Producto.includes(:categoria, :marca).all.order(:nombre).page(1).per(10)
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
      :categoria_id,
      :nombre_marca,
      :sku,
      :nombre,
      :descuento,
      :descuento_maximo,
      :stock_minimo_limite,
      :stock_maximo_limite
    )
  end
end
