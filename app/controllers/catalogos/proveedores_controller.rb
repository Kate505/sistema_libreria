class Catalogos::ProveedoresController < ApplicationController
  before_action :set_proveedor, only: %i[edit update destroy]

  def index
    @proveedor = Proveedor.new
    @proveedores = Proveedor.all.order(:nombre)

    if params[:q].present?
      q = "%#{params[:q]}%"
      @proveedores = @proveedores.where("nombre ILIKE :q OR telefono ILIKE :q OR direccion ILIKE :q", q: q)
    end

    @proveedores = @proveedores.page(params[:page]).per(10)
  end

  def edit
    @proveedor = Proveedor.find_by(id: params[:id])
    render partial: "form", locals: { proveedor: @proveedor }
  end

  def create
    @proveedor = Proveedor.new(proveedor_params)
    if @proveedor.save
      @proveedores = Proveedor.all.order(:nombre).page(1).per(10)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("proveedores_table", partial: "catalogos/proveedores/table", locals: { proveedores: @proveedores }),
            turbo_stream.replace("proveedor_form", partial: "catalogos/proveedores/form", locals: { proveedor: Proveedor.new })
          ]
        end
        format.html { redirect_to catalogos_proveedores_path, notice: "Creado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("proveedor_form", partial: "catalogos/proveedores/form", locals: { proveedor: @proveedor }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @proveedor.update(proveedor_params)
      @proveedores = Proveedor.all.order(:nombre).page(1).per(10)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("proveedores_table", partial: "catalogos/proveedores/table", locals: { proveedores: @proveedores }),
            turbo_stream.replace("proveedor_form", partial: "catalogos/proveedores/form", locals: { proveedor: Proveedor.new })
          ]
        end
        format.html { redirect_to catalogos_proveedores_path, notice: "Actualizado" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("proveedor_form", partial: "catalogos/proveedores/form", locals: { proveedor: @proveedor }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @proveedor.destroy
    @proveedores = Proveedor.all.order(:nombre).page(1).per(10)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("proveedores_table", partial: "catalogos/proveedores/table", locals: { proveedores: @proveedores }),
          turbo_stream.replace("proveedor_form", partial: "catalogos/proveedores/form", locals: { proveedor: Proveedor.new })
        ]
      end
      format.html { redirect_to catalogos_proveedores_path, notice: "Eliminado" }
    end
  end

  private

  def set_proveedor
    @proveedor = Proveedor.find(params[:id])
  end

  def proveedor_params
    params.require(:proveedor).permit(:nombre, :telefono, :direccion)
  end
end
