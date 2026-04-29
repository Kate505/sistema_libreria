class Configuraciones::NegocioController < ApplicationController
  before_action :set_configuracion

  # GET /configuraciones/negocio/edit
  def edit
  end

  # PATCH /configuraciones/negocio
  def update
    if @configuracion.update(configuracion_params)
      redirect_to edit_configuraciones_negocio_path, notice: "Configuración actualizada exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # POST /configuraciones/negocio/sugerir_valores
  # Calcula el % OpEx y ventas proyectadas desde el historial de los últimos 6 meses
  def sugerir_valores
    if @configuracion.sugerir_valores!(meses: 6)
      redirect_to edit_configuraciones_negocio_path,
                  notice: "Valores actualizados a partir del historial de los últimos 6 meses."
    else
      redirect_to edit_configuraciones_negocio_path,
                  alert: "No se pudieron calcular los valores sugeridos."
    end
  end

  private

  def set_configuracion
    @configuracion = ConfiguracionNegocio.configuracion
  end

  def configuracion_params
    raw = params.require(:configuracion_negocio).permit(
      :margen_ganancia_meta,
      :porcentaje_opex,
      :ventas_proyectadas_mes,
      :margen_alerta_minimo
    )

    # Los campos de porcentaje se ingresan como "40" en la UI pero se guardan como 0.40
    raw[:margen_ganancia_meta]  = raw[:margen_ganancia_meta].to_d  / 100 if raw[:margen_ganancia_meta].present?
    raw[:porcentaje_opex]       = raw[:porcentaje_opex].to_d       / 100 if raw[:porcentaje_opex].present?
    raw[:margen_alerta_minimo]  = raw[:margen_alerta_minimo].to_d  / 100 if raw[:margen_alerta_minimo].present?

    raw
  end
end
