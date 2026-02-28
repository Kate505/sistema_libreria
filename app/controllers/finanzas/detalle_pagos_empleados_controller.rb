class Finanzas::DetallePagosEmpleadosController < ApplicationController
  before_action :set_gasto_operativo
  before_action :set_detalle, only: %i[edit update destroy]

  # GET /finanzas/gastos_operativos/:gasto_operativo_id/detalle_pagos_empleados/:id/edit
  def edit
    respond_to do |format|
      format.html do
        @detalle_pagos_empleados = @gasto_operativo.detalle_pagos_empleados
                                                   .includes(:empleado)
                                                   .order(:created_at)
        render "finanzas/gastos_operativos/show"
      end
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "detalle_pago_empleado_form",
          partial: "finanzas/detalle_pagos_empleados/form",
          locals: { gasto_operativo: @gasto_operativo,
                    detalle_pago_empleado: @detalle_pago_empleado }
        )
      end
    end
  end

  # POST /finanzas/gastos_operativos/:gasto_operativo_id/detalle_pagos_empleados
  def create
    @detalle_pago_empleado = @gasto_operativo.detalle_pagos_empleados.new(detalle_params)

    if @detalle_pago_empleado.save
      @detalle_pagos_empleados = @gasto_operativo.detalle_pagos_empleados
                                                 .includes(:empleado)
                                                 .order(:created_at)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(
              "detalle_pagos_empleados_table",
              partial: "finanzas/detalle_pagos_empleados/table",
              locals: { gasto_operativo: @gasto_operativo,
                        detalle_pagos_empleados: @detalle_pagos_empleados }
            ),
            turbo_stream.replace(
              "detalle_pago_empleado_form",
              partial: "finanzas/detalle_pagos_empleados/form",
              locals: { gasto_operativo: @gasto_operativo,
                        detalle_pago_empleado: DetallePagoEmpleado.new }
            ),
            turbo_stream.replace(
              "gasto_operativo_resumen",
              partial: "finanzas/gastos_operativos/resumen",
              locals: { gasto_operativo: @gasto_operativo.reload }
            )
          ]
        end
        format.html do
          redirect_to finanzas_gasto_operativo_path(@gasto_operativo),
                      notice: "Pago de empleado registrado exitosamente."
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "detalle_pago_empleado_form",
            partial: "finanzas/detalle_pagos_empleados/form",
            locals: { gasto_operativo: @gasto_operativo,
                      detalle_pago_empleado: @detalle_pago_empleado }
          )
        end
        format.html do
          @detalle_pagos_empleados = @gasto_operativo.detalle_pagos_empleados
                                                     .includes(:empleado)
                                                     .order(:created_at)
          render "finanzas/gastos_operativos/show", status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH /finanzas/gastos_operativos/:gasto_operativo_id/detalle_pagos_empleados/:id
  def update
    if @detalle_pago_empleado.update(detalle_params)
      @detalle_pagos_empleados = @gasto_operativo.detalle_pagos_empleados
                                                 .includes(:empleado)
                                                 .order(:created_at)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(
              "detalle_pagos_empleados_table",
              partial: "finanzas/detalle_pagos_empleados/table",
              locals: { gasto_operativo: @gasto_operativo,
                        detalle_pagos_empleados: @detalle_pagos_empleados }
            ),
            turbo_stream.replace(
              "detalle_pago_empleado_form",
              partial: "finanzas/detalle_pagos_empleados/form",
              locals: { gasto_operativo: @gasto_operativo,
                        detalle_pago_empleado: DetallePagoEmpleado.new }
            ),
            turbo_stream.replace(
              "gasto_operativo_resumen",
              partial: "finanzas/gastos_operativos/resumen",
              locals: { gasto_operativo: @gasto_operativo.reload }
            )
          ]
        end
        format.html do
          redirect_to finanzas_gasto_operativo_path(@gasto_operativo),
                      notice: "Pago de empleado actualizado exitosamente."
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "detalle_pago_empleado_form",
            partial: "finanzas/detalle_pagos_empleados/form",
            locals: { gasto_operativo: @gasto_operativo,
                      detalle_pago_empleado: @detalle_pago_empleado }
          )
        end
        format.html do
          @detalle_pagos_empleados = @gasto_operativo.detalle_pagos_empleados
                                                     .includes(:empleado)
                                                     .order(:created_at)
          render "finanzas/gastos_operativos/show", status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /finanzas/gastos_operativos/:gasto_operativo_id/detalle_pagos_empleados/:id
  def destroy
    @detalle_pago_empleado.destroy
    @detalle_pagos_empleados = @gasto_operativo.detalle_pagos_empleados
                                               .includes(:empleado)
                                               .order(:created_at)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update(
            "detalle_pagos_empleados_table",
            partial: "finanzas/detalle_pagos_empleados/table",
            locals: { gasto_operativo: @gasto_operativo,
                      detalle_pagos_empleados: @detalle_pagos_empleados }
          ),
          turbo_stream.replace(
            "detalle_pago_empleado_form",
            partial: "finanzas/detalle_pagos_empleados/form",
            locals: { gasto_operativo: @gasto_operativo,
                      detalle_pago_empleado: DetallePagoEmpleado.new }
          ),
          turbo_stream.replace(
            "gasto_operativo_resumen",
            partial: "finanzas/gastos_operativos/resumen",
            locals: { gasto_operativo: @gasto_operativo.reload }
          )
        ]
      end
      format.html do
        redirect_to finanzas_gasto_operativo_path(@gasto_operativo),
                    notice: "Pago de empleado eliminado exitosamente."
      end
    end
  end

  private

  def set_gasto_operativo
    @gasto_operativo = GastoOperativo.find(params[:gasto_operativo_id])
  end

  def set_detalle
    @detalle_pago_empleado = @gasto_operativo.detalle_pagos_empleados.find(params[:id])
  end

  def detalle_params
    params.require(:detalle_pago_empleado).permit(
      :empleado_id,
      :salario_base,
      :pago_transporte,
      :comisiones_ventas,
      :horas_extra,
      :deduccion_inss,
      :deduccion_impuestos,
      :otras_deducciones
    )
  end
end
