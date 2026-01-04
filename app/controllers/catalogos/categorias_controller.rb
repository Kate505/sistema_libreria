class Catalogos::CategoriasController < ApplicationController
  before_action :set_categoria, only: %i[edit update destroy]

  def index
    @categoria = Categoria.new
    @categorias = Categoria.all.order(:nombre)
  end

  def edit
    @categoria = Categoria.find_by(id: params[:id])
    render partial: "form", locals: { categoria: @categoria }
  end

  def create
    @categoria = Categoria.new(categoria_params)
    if @categoria.save
      @categorias = Categoria.all.order(:nombre)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("categorias_table", partial: "catalogos/categorias/table", locals: { categorias: @categorias }),

            turbo_stream.replace("categoria_form", partial: "catalogos/categorias/form", locals: { categoria: Categoria.new })
          ]
        end
        format.html { redirect_to catalogos_categorias_path, notice: "Creado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("categoria_form", partial: "catalogos/categorias/form", locals: { categoria: @categoria }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @categoria.update(categoria_params)
      @categorias = Categoria.all.order(:nombre)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("categorias_table", partial: "catalogos/categorias/table", locals: { categorias: @categorias }),
            turbo_stream.replace("categoria_form", partial: "catalogos/categorias/form", locals: { categoria: Categoria.new })
          ]
        end
        format.html { redirect_to catalogos_categorias_path, notice: "Actualizado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("categoria_form", partial: "catalogos/categorias/form", locals: { categoria: @categoria }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @categoria.destroy
    @categorias = Categoria.all.order(:nombre)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("categorias_table", partial: "catalogos/categorias/table", locals: { categorias: @categorias }),
          turbo_stream.replace("categoria_form", partial: "catalogos/categorias/form", locals: { categoria: Categoria.new })
        ]
      end
      format.html { redirect_to catalogos_categorias_path, notice: "Eliminado" }
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
