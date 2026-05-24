class Finanzas::GastosOperativosController < ApplicationController
  before_action :set_gasto_operativo, only: %i[show edit update destroy]

  def show
  end

  def index
    @gasto_operativo = GastoOperativo.new
    @gastos_operativos = GastoOperativo.por_fecha_desc

    if params[:q].present?
      @gastos_operativos = @gastos_operativos.buscar(params[:q])
    end

    if params[:fecha_desde].present? || params[:fecha_hasta].present?
      @gastos_operativos = @gastos_operativos.por_rango_fecha(params[:fecha_desde], params[:fecha_hasta])
    end

    @gastos_operativos = @gastos_operativos.page(params[:page]).per(10)
  end

  def edit
    respond_to do |format|
      format.html do
        @gastos_operativos = GastoOperativo.por_fecha_desc.page(1).per(10)
        render :index
      end
      format.turbo_stream do
        frame_id = request.headers["Turbo-Frame"].presence || "gasto_operativo_form_desktop"
        suffix = frame_id.end_with?("_mobile") ? "mobile" : "desktop"
        render turbo_stream: turbo_stream.replace(
          frame_id,
          partial: "finanzas/gastos_operativos/form",
          locals: { gasto_operativo: @gasto_operativo, suffix: suffix }
        )
      end
    end
  end

  def create
    @gasto_operativo = GastoOperativo.new(gasto_operativo_params)
    @gasto_operativo.user = Current.user

    if @gasto_operativo.save
      @gastos_operativos = GastoOperativo.por_fecha_desc.page(1).per(10)
      flash.now[:notice] = "Gasto operativo creado exitosamente."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("gastos_operativos_table",
                                partial: "finanzas/gastos_operativos/table",
                                locals: { gastos_operativos: @gastos_operativos }),
            turbo_stream.replace("gasto_operativo_form_desktop",
                                 partial: "finanzas/gastos_operativos/form",
                                 locals: { gasto_operativo: GastoOperativo.new, suffix: "desktop" }),
            turbo_stream.replace("gasto_operativo_form_mobile",
                                 partial: "finanzas/gastos_operativos/form",
                                 locals: { gasto_operativo: GastoOperativo.new, suffix: "mobile", saved: true }),
            turbo_stream.update("flash-messages",
                                partial: "shared/flash")
          ]
        end
        format.html { redirect_to finanzas_gastos_operativos_path, notice: "Gasto operativo creado exitosamente." }
      end
    else
      flash.now[:alert] = "No se pudo crear el gasto operativo."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("gasto_operativo_form_desktop",
                                 partial: "finanzas/gastos_operativos/form",
                                 locals: { gasto_operativo: @gasto_operativo, suffix: "desktop" }),
            turbo_stream.replace("gasto_operativo_form_mobile",
                                 partial: "finanzas/gastos_operativos/form",
                                 locals: { gasto_operativo: @gasto_operativo, suffix: "mobile" }),
            turbo_stream.update("flash-messages",
                                partial: "shared/flash")
          ]
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @gasto_operativo.update(gasto_operativo_params)
      @gastos_operativos = GastoOperativo.por_fecha_desc.page(1).per(10)
      flash.now[:notice] = "Gasto operativo actualizado exitosamente."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("gastos_operativos_table",
                                partial: "finanzas/gastos_operativos/table",
                                locals: { gastos_operativos: @gastos_operativos }),
            turbo_stream.replace("gasto_operativo_form_desktop",
                                 partial: "finanzas/gastos_operativos/form",
                                 locals: { gasto_operativo: GastoOperativo.new, suffix: "desktop" }),
            turbo_stream.replace("gasto_operativo_form_mobile",
                                 partial: "finanzas/gastos_operativos/form",
                                 locals: { gasto_operativo: GastoOperativo.new, suffix: "mobile", saved: true }),
            turbo_stream.update("flash-messages",
                                partial: "shared/flash")
          ]
        end
        format.html { redirect_to finanzas_gastos_operativos_path, notice: "Gasto operativo actualizado exitosamente." }
      end
    else
      flash.now[:alert] = "No se pudo actualizar el gasto operativo."
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("gasto_operativo_form_desktop",
                                 partial: "finanzas/gastos_operativos/form",
                                 locals: { gasto_operativo: @gasto_operativo, suffix: "desktop" }),
            turbo_stream.replace("gasto_operativo_form_mobile",
                                 partial: "finanzas/gastos_operativos/form",
                                 locals: { gasto_operativo: @gasto_operativo, suffix: "mobile" }),
            turbo_stream.update("flash-messages",
                                partial: "shared/flash")
          ]
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    unless Current.user.can_access_menu?("ELIMINAR_GASTOS")
      flash.now[:alert] = "No tienes permisos para eliminar gastos operativos."
      respond_to do |format|
        format.html { redirect_to finanzas_gastos_operativos_path, alert: "No tienes permisos para eliminar gastos operativos." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flash")
        end
      end
      return
    end

    @gasto_operativo.destroy
    @gastos_operativos = GastoOperativo.por_fecha_desc.page(1).per(10)
    flash.now[:notice] = "Gasto operativo eliminado exitosamente."
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("gastos_operativos_table",
                              partial: "finanzas/gastos_operativos/table",
                              locals: { gastos_operativos: @gastos_operativos }),
          turbo_stream.replace("gasto_operativo_form_desktop",
                               partial: "finanzas/gastos_operativos/form",
                               locals: { gasto_operativo: GastoOperativo.new, suffix: "desktop" }),
          turbo_stream.replace("gasto_operativo_form_mobile",
                               partial: "finanzas/gastos_operativos/form",
                               locals: { gasto_operativo: GastoOperativo.new, suffix: "mobile" }),
          turbo_stream.update("flash-messages",
                              partial: "shared/flash")
        ]
      end
      format.html { redirect_to finanzas_gastos_operativos_path, notice: "Gasto operativo eliminado exitosamente." }
    end
  end

  private

  def set_gasto_operativo
    @gasto_operativo = GastoOperativo.find(params[:id])
  end

  def gasto_operativo_params
    params.require(:gasto_operativo).permit(:fecha, :cantidad, :descripcion)
  end
end
