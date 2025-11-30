class Seguridad::ModulosController < ApplicationController
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
      respond_to do |format|
        format.turbo_stream do
          @modulos = Modulo.all.order(:nombre)
          render "create"
        end
        format.html { redirect_to seguridad_modulos_path }
      end
    else
      render partial: "form", status: :unprocessable_entity
    end
  end

  def update
    @modulo = Modulo.find(params[:id])

    if @modulo.update(modulo_params)
      respond_to do |format|
        format.turbo_stream do
          @modulos = Modulo.all.order(:nombre)
          @modulo = Modulo.new
          render "update"
        end
        format.html { redirect_to seguridad_modulos_path }
      end
    else
      render partial: "form", status: :unprocessable_entity
    end
  end

  def destroy
    @modulo = Modulo.find(params[:id])
    @modulo.destroy

    respond_to do |format|
      format.turbo_stream do
        @modulos = Modulo.all.order(:nombre)
        render "destroy"
      end
      format.html { redirect_to seguridad_modulos_path }
    end
  end

  private

  def modulo_params
    params.require(:modulo).permit(:nombre, :icono, :link_to, :pasivo)
  end
end
