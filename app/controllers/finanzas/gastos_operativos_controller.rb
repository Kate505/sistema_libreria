class Finanzas::GastosOperativosController < ApplicationController
  before_action :set_gasto_operativo, only: %i[show edit update destroy]

  def show
  end

  def index
    @gasto_operativo = GastoOperativo.new
    @gastos_operativos = GastoOperativo.all.order(periodo_year: :desc, periodo_mes: :desc)
  end

  def edit
    respond_to do |format|
      format.html do
        @gastos_operativos = GastoOperativo.all.order(periodo_year: :desc, periodo_mes: :desc)
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

    if @gasto_operativo.save
      @gastos_operativos = GastoOperativo.all.order(periodo_year: :desc, periodo_mes: :desc)
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
      @gastos_operativos = GastoOperativo.all.order(periodo_year: :desc, periodo_mes: :desc)
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
    @gasto_operativo.destroy
    @gastos_operativos = GastoOperativo.all.order(periodo_year: :desc, periodo_mes: :desc)
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
    params.require(:gasto_operativo).permit(
      :periodo_mes,
      :periodo_year,
      :costos_alquiler,
      :costo_utilidades,
      :costo_mantenimiento
    )
  end
end
