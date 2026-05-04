class Finanzas::EgresosController < ApplicationController
  before_action :set_egreso, only: %i[edit update destroy]

  def index
    @egreso       = Egreso.new
    @categorias   = CategoriaEgreso.order(:nombre)
    @categoria_egreso = CategoriaEgreso.new
    cargar_vista
  end

  def create
    @egreso     = Egreso.new(egreso_params)
    @categorias = CategoriaEgreso.order(:nombre)

    if @egreso.save
      cargar_vista
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("egresos_table",
              partial: "finanzas/egresos/table",
              locals: { egresos: @egresos, total_egresos: @total_egresos,
                        total_ventas: @total_ventas, utilidad_neta: @utilidad_neta }),
            turbo_stream.replace("egreso_form",
              partial: "finanzas/egresos/form",
              locals: { egreso: Egreso.new, categorias: @categorias })
          ]
        end
        format.html { redirect_to finanzas_egresos_path, notice: "Gasto registrado." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("egreso_form",
            partial: "finanzas/egresos/form",
            locals: { egreso: @egreso, categorias: @categorias })
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @categorias = CategoriaEgreso.order(:nombre)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("egreso_form",
          partial: "finanzas/egresos/form",
          locals: { egreso: @egreso, categorias: @categorias })
      end
    end
  end

  def update
    @categorias = CategoriaEgreso.order(:nombre)
    if @egreso.update(egreso_params)
      cargar_vista
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("egresos_table",
              partial: "finanzas/egresos/table",
              locals: { egresos: @egresos, total_egresos: @total_egresos,
                        total_ventas: @total_ventas, utilidad_neta: @utilidad_neta }),
            turbo_stream.replace("egreso_form",
              partial: "finanzas/egresos/form",
              locals: { egreso: Egreso.new, categorias: @categorias })
          ]
        end
        format.html { redirect_to finanzas_egresos_path, notice: "Gasto actualizado." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("egreso_form",
            partial: "finanzas/egresos/form",
            locals: { egreso: @egreso, categorias: @categorias })
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @egreso.destroy
    cargar_vista
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("egresos_table",
          partial: "finanzas/egresos/table",
          locals: { egresos: @egresos, total_egresos: @total_egresos,
                    total_ventas: @total_ventas, utilidad_neta: @utilidad_neta })
      end
      format.html { redirect_to finanzas_egresos_path, notice: "Gasto eliminado." }
    end
  end

  private

  def set_egreso
    @egreso = Egreso.find(params[:id])
  end

  def egreso_params
    params.require(:egreso).permit(:categoria_egreso_id, :monto, :descripcion, :comprobante)
  end

  def cargar_vista
    @fecha_desde = Time.current.beginning_of_week
    @fecha_hasta = Time.current.end_of_week

    # Cargar egresos de las últimas 12 semanas para el acordeón
    @egresos = Egreso.includes(:categoria_egreso)
                     .where(fecha: 12.weeks.ago.beginning_of_week..@fecha_hasta)
                     .order(fecha: :desc)

    # KPIs sólo de la semana actual
    egresos_semana_actual = @egresos.select { |e| e.fecha >= @fecha_desde && e.fecha <= @fecha_hasta }
    @total_egresos = egresos_semana_actual.sum(&:monto).to_f
    @total_ventas  = Venta.where(fecha_venta: @fecha_desde..@fecha_hasta, finalizada: true)
                          .sum(:cantidad_total).to_f
    @utilidad_neta = @total_ventas - @total_egresos
  end
end
