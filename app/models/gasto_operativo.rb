class GastoOperativo < ApplicationRecord
  self.table_name = "gastos_operativos"

  has_many :detalle_pagos_empleados,
           dependent: :destroy

  validates :periodo_mes,
            presence: true,
            inclusion: { in: 1..12, message: "Debe ser un número entre 1 y 12" }

  validates :periodo_year,
            presence: true,
            numericality: { only_integer: true, greater_than: 2000 }

  validates :periodo_mes,
            uniqueness: {
              scope: :periodo_year,
              message: "ya ha sido registrado para este año"
            }

  validates :costos_alquiler, :costo_utilidades, :costo_mantenimiento, :costo_salario_total,
            numericality: { greater_than_or_equal_to: 0 }

  before_save :calcular_total_gastos

  NOMBRES_MESES = {
    1 => "Enero", 2 => "Febrero", 3 => "Marzo", 4 => "Abril",
    5 => "Mayo", 6 => "Junio", 7 => "Julio", 8 => "Agosto",
    9 => "Septiembre", 10 => "Octubre", 11 => "Noviembre", 12 => "Diciembre"
  }.freeze

  def nombre_mes
    return unless periodo_mes
    NOMBRES_MESES[periodo_mes]
  end

  def periodo_legible
    "#{nombre_mes} #{periodo_year}"
  end

  def importar_costo_nomina!
    total_nomina = Empleado.activos.sum(:salario_base)
    total_viaticos = Empleado.activos.sum(:viatico_transporte)

    self.costo_salario_total = total_nomina + total_viaticos
    save
  end

  private

  def calcular_total_gastos
    self.gran_total_gastos = [
      costos_alquiler,
      costo_utilidades,
      costo_mantenimiento,
      costo_salario_total
    ].sum
  end
end
