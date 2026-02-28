class Finanzas::NominaEmpleadosController < ApplicationController

  def index
    # Lista de períodos disponibles (ordenados del más reciente al más antiguo)
    @periodos = GastoOperativo.all.order(periodo_year: :desc, periodo_mes: :desc)

    # Período activo: primero el de params, luego el más reciente
    @gasto_operativo = if params[:gasto_operativo_id].present?
                         GastoOperativo.find_by(id: params[:gasto_operativo_id])
                       end
    @gasto_operativo ||= @periodos.first

    if @gasto_operativo
      @detalle_pago_empleado   = DetallePagoEmpleado.new
      @detalle_pagos_empleados = @gasto_operativo
                                   .detalle_pagos_empleados
                                   .includes(:empleado)
                                   .order(:created_at)
    end
  end

end
