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
    frame_id = request.headers["Turbo-Frame"].presence || "proveedor_form_desktop"
    suffix = frame_id.end_with?("_mobile") ? "mobile" : "desktop"
    render partial: "form", locals: { proveedor: @proveedor, suffix: suffix }
  end

  def create
    @proveedor = Proveedor.new(proveedor_params)
    if @proveedor.save
      @proveedores = Proveedor.all.order(:nombre).page(1).per(10)
      flash.now[:notice] = "Proveedor creado exitosamente."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("proveedores_table", partial: "catalogos/proveedores/table", locals: { proveedores: @proveedores }),
            turbo_stream.replace("proveedor_form_desktop", partial: "catalogos/proveedores/form", locals: { proveedor: Proveedor.new, suffix: "desktop" }),
            turbo_stream.replace("proveedor_form_mobile", partial: "catalogos/proveedores/form", locals: { proveedor: Proveedor.new, suffix: "mobile", saved: true }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { redirect_to catalogos_proveedores_path, notice: "Proveedor creado exitosamente." }
      end
    else
      flash.now[:alert] = "No se pudo crear el proveedor."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("proveedor_form_desktop", partial: "catalogos/proveedores/form", locals: { proveedor: @proveedor, suffix: "desktop" }),
            turbo_stream.replace("proveedor_form_mobile", partial: "catalogos/proveedores/form", locals: { proveedor: @proveedor, suffix: "mobile" }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @proveedor.update(proveedor_params)
      @proveedores = Proveedor.all.order(:nombre).page(1).per(10)
      flash.now[:notice] = "Proveedor actualizado exitosamente."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("proveedores_table", partial: "catalogos/proveedores/table", locals: { proveedores: @proveedores }),
            turbo_stream.replace("proveedor_form_desktop", partial: "catalogos/proveedores/form", locals: { proveedor: Proveedor.new, suffix: "desktop" }),
            turbo_stream.replace("proveedor_form_mobile", partial: "catalogos/proveedores/form", locals: { proveedor: Proveedor.new, suffix: "mobile", saved: true }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { redirect_to catalogos_proveedores_path, notice: "Proveedor actualizado exitosamente." }
      end
    else
      flash.now[:alert] = "No se pudo actualizar el proveedor."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("proveedor_form_desktop", partial: "catalogos/proveedores/form", locals: { proveedor: @proveedor, suffix: "desktop" }),
            turbo_stream.replace("proveedor_form_mobile", partial: "catalogos/proveedores/form", locals: { proveedor: @proveedor, suffix: "mobile" }),
            turbo_stream.update("flash-messages", partial: "shared/flash")
          ]
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @proveedor.destroy
    @proveedores = Proveedor.all.order(:nombre).page(1).per(10)
    flash.now[:notice] = "Proveedor eliminado exitosamente."
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("proveedores_table", partial: "catalogos/proveedores/table", locals: { proveedores: @proveedores }),
          turbo_stream.replace("proveedor_form_desktop", partial: "catalogos/proveedores/form", locals: { proveedor: Proveedor.new, suffix: "desktop" }),
          turbo_stream.replace("proveedor_form_mobile", partial: "catalogos/proveedores/form", locals: { proveedor: Proveedor.new, suffix: "mobile" }),
          turbo_stream.update("flash-messages", partial: "shared/flash")
        ]
      end
      format.html { redirect_to catalogos_proveedores_path, notice: "Proveedor eliminado exitosamente." }
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
