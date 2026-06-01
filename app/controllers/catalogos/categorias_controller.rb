class Catalogos::CategoriasController < ApplicationController
  before_action :set_categoria, only: %i[edit update destroy]

  def index
    @categoria = Categoria.new
    @categorias = Categoria.all.order(:nombre)

    if params[:q].present?
      @categorias = @categorias.where("nombre ILIKE ?", "%#{params[:q]}%")
    end

    @categorias = @categorias.page(params[:page]).per(10)
  end

  def edit
    frame_id = request.headers["Turbo-Frame"].presence || "categoria_form_desktop"
    suffix = frame_id.end_with?("_mobile") ? "mobile" : "desktop"
    render partial: "form", locals: { categoria: @categoria, suffix: suffix }
  end

  def create
    @categoria = Categoria.new(categoria_params)
    if @categoria.save
      @categorias = Categoria.all.order(:nombre).page(1).per(10)
      flash.now[:notice] = "Categoría creada exitosamente."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("categorias_table", partial: "catalogos/categorias/table", locals: { categorias: @categorias }),
            turbo_stream.replace("categoria_form_desktop", partial: "catalogos/categorias/form", locals: { categoria: Categoria.new, suffix: "desktop" }),
            turbo_stream.replace("categoria_form_mobile", partial: "catalogos/categorias/form", locals: { categoria: Categoria.new, suffix: "mobile", saved: true }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { redirect_to catalogos_categorias_path, notice: "Categoría creada exitosamente." }
      end
    else
      flash.now[:alert] = "No se pudo crear la categoría."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("categoria_form_desktop", partial: "catalogos/categorias/form", locals: { categoria: @categoria, suffix: "desktop" }),
            turbo_stream.replace("categoria_form_mobile", partial: "catalogos/categorias/form", locals: { categoria: @categoria, suffix: "mobile" }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @categoria.update(categoria_params)
      @categorias = Categoria.all.order(:nombre).page(1).per(10)
      flash.now[:notice] = "Categoría actualizada exitosamente."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("categorias_table", partial: "catalogos/categorias/table", locals: { categorias: @categorias }),
            turbo_stream.replace("categoria_form_desktop", partial: "catalogos/categorias/form", locals: { categoria: Categoria.new, suffix: "desktop" }),
            turbo_stream.replace("categoria_form_mobile", partial: "catalogos/categorias/form", locals: { categoria: Categoria.new, suffix: "mobile", saved: true }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { redirect_to catalogos_categorias_path, notice: "Categoría actualizada exitosamente." }
      end
    else
      flash.now[:alert] = "No se pudo actualizar la categoría."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("categoria_form_desktop", partial: "catalogos/categorias/form", locals: { categoria: @categoria, suffix: "desktop" }),
            turbo_stream.replace("categoria_form_mobile", partial: "catalogos/categorias/form", locals: { categoria: @categoria, suffix: "mobile" }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @categoria.destroy
    @categorias = Categoria.all.order(:nombre).page(1).per(10)
    flash.now[:notice] = "Categoría eliminada exitosamente."
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("categorias_table", partial: "catalogos/categorias/table", locals: { categorias: @categorias }),
          turbo_stream.replace("categoria_form_desktop", partial: "catalogos/categorias/form", locals: { categoria: Categoria.new, suffix: "desktop" }),
          turbo_stream.replace("categoria_form_mobile", partial: "catalogos/categorias/form", locals: { categoria: Categoria.new, suffix: "mobile" }),
          turbo_stream.update("flash-messages", partial: "shared/flash")
        ]
      end
      format.html { redirect_to catalogos_categorias_path, notice: "Categoría eliminada exitosamente." }
    end
  end

  private

  def set_categoria
    @categoria = Categoria.find(params[:id])
  end

  def categoria_params
    params.require(:categoria).permit(:nombre)
  end
end
