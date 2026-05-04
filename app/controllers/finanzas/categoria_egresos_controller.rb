class Finanzas::CategoriaEgresosController < ApplicationController
  before_action :set_categoria, only: %i[update destroy]

  def create
    @categoria_egreso = CategoriaEgreso.new(categoria_params)
    if @categoria_egreso.save
      @categorias = CategoriaEgreso.order(:nombre)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("categorias_list",
              partial: "finanzas/egresos/categorias_list",
              locals: { categorias: @categorias }),
            turbo_stream.replace("categoria_egreso_form",
              partial: "finanzas/egresos/categoria_form",
              locals: { categoria_egreso: CategoriaEgreso.new }),
            turbo_stream.update("egreso_categoria_select",
              partial: "finanzas/egresos/categoria_select",
              locals: { categorias: @categorias, selected_id: nil })
          ]
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("categoria_egreso_form",
            partial: "finanzas/egresos/categoria_form",
            locals: { categoria_egreso: @categoria_egreso })
        end
      end
    end
  end

  def update
    if @categoria_egreso.update(categoria_params)
      @categorias = CategoriaEgreso.order(:nombre)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("categorias_list",
              partial: "finanzas/egresos/categorias_list",
              locals: { categorias: @categorias }),
            turbo_stream.replace("categoria_egreso_form",
              partial: "finanzas/egresos/categoria_form",
              locals: { categoria_egreso: CategoriaEgreso.new }),
            turbo_stream.update("egreso_categoria_select",
              partial: "finanzas/egresos/categoria_select",
              locals: { categorias: @categorias, selected_id: nil })
          ]
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("categoria_egreso_form",
            partial: "finanzas/egresos/categoria_form",
            locals: { categoria_egreso: @categoria_egreso })
        end
      end
    end
  end

  def destroy
    if @categoria_egreso.destroy
      @categorias = CategoriaEgreso.order(:nombre)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("categorias_list",
              partial: "finanzas/egresos/categorias_list",
              locals: { categorias: @categorias }),
            turbo_stream.update("egreso_categoria_select",
              partial: "finanzas/egresos/categoria_select",
              locals: { categorias: @categorias, selected_id: nil })
          ]
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("categoria_egreso_form",
            partial: "finanzas/egresos/categoria_form",
            locals: { categoria_egreso: @categoria_egreso })
        end
      end
    end
  end

  private

  def set_categoria
    @categoria_egreso = CategoriaEgreso.find(params[:id])
  end

  def categoria_params
    params.require(:categoria_egreso).permit(:nombre, :descripcion)
  end
end
