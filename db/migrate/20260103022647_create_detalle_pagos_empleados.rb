class CreateDetallePagosEmpleados < ActiveRecord::Migration[8.0]
  def change
    create_table :detalle_pagos_empleados do |t|
      t.references :gasto_operativo, null: false, foreign_key: true
      t.references :empleado, null: false, foreign_key: true

      t.decimal :salario_base, precision: 10, scale: 2
      t.decimal :pago_transporte, precision: 10, scale: 2
      t.decimal :comisiones_ventas, precision: 10, scale: 2
      t.decimal :horas_extra, precision: 10, scale: 2, default: 0.00

      t.decimal :salario_bruto, precision: 10, scale: 2

      t.decimal :deduccion_inss, precision: 10, scale: 2
      t.decimal :deduccion_impuestos, precision: 10, scale: 2
      t.decimal :otras_deducciones, precision: 10, scale: 2, default: 0.00

      t.decimal :salario_neto, precision: 10, scale: 2

      t.timestamps
    end
  end
end
