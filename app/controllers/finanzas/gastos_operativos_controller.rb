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
        render turbo_stream: turbo_stream.replace(
          "gasto_operativo_form",
          partial: "finanzas/gastos_operativos/form",
          locals: { gasto_operativo: @gasto_operativo }
        )
      end
    end
  end

  def create
    @gasto_operativo = GastoOperativo.new(gasto_operativo_params)
    @gasto_operativo.user = Current.user

    if @gasto_operativo.save
      @gastos_operativos = GastoOperativo.por_fecha_desc.page(1).per(10)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("gastos_operativos_table",
                                partial: "finanzas/gastos_operativos/table",
                                locals: { gastos_operativos: @gastos_operativos }),
            turbo_stream.replace("gasto_operativo_form",
                                 partial: "finanzas/gastos_operativos/form",
                                 locals: { gasto_operativo: GastoOperativo.new })
          ]
        end
        format.html { redirect_to finanzas_gastos_operativos_path, notice: "Gasto operativo creado exitosamente." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "gasto_operativo_form",
            partial: "finanzas/gastos_operativos/form",
            locals: { gasto_operativo: @gasto_operativo }
          )
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @gasto_operativo.update(gasto_operativo_params)
      @gastos_operativos = GastoOperativo.por_fecha_desc.page(1).per(10)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("gastos_operativos_table",
                                partial: "finanzas/gastos_operativos/table",
                                locals: { gastos_operativos: @gastos_operativos }),
            turbo_stream.replace("gasto_operativo_form",
                                 partial: "finanzas/gastos_operativos/form",
                                 locals: { gasto_operativo: GastoOperativo.new })
          ]
        end
        format.html { redirect_to finanzas_gastos_operativos_path, notice: "Gasto operativo actualizado exitosamente." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "gasto_operativo_form",
            partial: "finanzas/gastos_operativos/form",
            locals: { gasto_operativo: @gasto_operativo }
          )
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
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("gastos_operativos_table",
                              partial: "finanzas/gastos_operativos/table",
                              locals: { gastos_operativos: @gastos_operativos }),
          turbo_stream.replace("gasto_operativo_form",
                               partial: "finanzas/gastos_operativos/form",
                               locals: { gasto_operativo: GastoOperativo.new })
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
