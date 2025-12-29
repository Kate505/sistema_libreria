class Seguridad::ModulosController < ApplicationController
  before_action :set_modulo, only: %i[edit update destroy]

  def index
    @modulo = Modulo.new
    @modulos = Modulo.all.order(:nombre)
  end

  def edit
    @modulo = Modulo.find_by(id: params[:id])
    render partial: "form", locals: { modulo: @modulo }
  end

  def create
    @modulo = Modulo.new(modulo_params)
    if @modulo.save
      @modulos = Modulo.all.order(:nombre)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("modulos_table", partial: "seguridad/modulos/table", locals: { modulos: @modulos }),

            turbo_stream.replace("modulo_form", partial: "seguridad/modulos/form", locals: { modulo: Modulo.new })
          ]
        end
        format.html { redirect_to seguridad_modulos_path, notice: "Creado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("modulo_form", partial: "seguridad/modulos/form", locals: { modulo: @modulo }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @modulo.update(modulo_params)
      @modulos = Modulo.all.order(:nombre)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("modulos_table", partial: "seguridad/modulos/table", locals: { modulos: @modulos }),
            turbo_stream.replace("modulo_form", partial: "seguridad/modulos/form", locals: { modulo: Modulo.new })
          ]
        end
        format.html { redirect_to seguridad_modulos_path, notice: "Actualizado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("modulo_form", partial: "seguridad/modulos/form", locals: { modulo: @modulo }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @modulo.destroy
    @modulos = Modulo.all.order(:nombre)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("modulos_table", partial: "seguridad/modulos/table", locals: { modulos: @modulos }),
          turbo_stream.replace("modulo_form", partial: "seguridad/modulos/form", locals: { modulo: Modulo.new })
        ]
      end
      format.html { redirect_to seguridad_modulos_path, notice: "Eliminado" }
    end
  end

  private

  def set_modulo
    @modulo = Modulo.find(params[:id])
  end

  def modulo_params
    params.require(:modulo).permit(:nombre, :icono, :link_to, :pasivo)
  end
end
