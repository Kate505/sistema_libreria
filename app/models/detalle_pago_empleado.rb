class DetallePagoEmpleado < ApplicationRecord
  self.table_name = "detalle_pagos_empleados"

  belongs_to :gasto_operativo
  belongs_to :empleado

  validates :empleado_id,
            uniqueness: {
              scope: :gasto_operativo_id,
              message: "ya tiene un pago registrado en este periodo"
            }

  validates :salario_base,
            :pago_transporte,
            :comisiones_ventas,
            :horas_extra,
            :salario_bruto,
            :deduccion_inss,
            :deduccion_impuestos,
            :otras_deducciones,
            :salario_neto,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  before_validation :cargar_datos_por_defecto, on: :create
  before_validation :calcular_nómina

  after_save :actualizar_gasto_operativo
  after_destroy :actualizar_gasto_operativo

  private

  def cargar_datos_por_defecto
    return unless empleado.present?

    self.salario_base ||= empleado.salario_base
    self.pago_transporte ||= empleado.viatico_transporte

    self.comisiones_ventas ||= 0.00
    self.horas_extra ||= 0.00
    self.deduccion_impuestos ||= 0.00
    self.otras_deducciones ||= 0.00

    self.deduccion_inss ||= (self.salario_base.to_f * 0.07).round(2)
  end

  def calcular_nómina
    self.salario_bruto = [
      salario_base,
      pago_transporte,
      comisiones_ventas,
      horas_extra
    ].compact.sum

    total_deducciones = [
      deduccion_inss,
      deduccion_impuestos,
      otras_deducciones
    ].compact.sum

    neto = self.salario_bruto - total_deducciones
    self.salario_neto = [neto, 0].max
  end

  def actualizar_gasto_operativo
    return unless gasto_operativo.present?

    total_nomina = gasto_operativo.detalle_pagos_empleados.sum(:salario_bruto)

    gasto_operativo.update(costo_salario_total: total_nomina)
  end
end
