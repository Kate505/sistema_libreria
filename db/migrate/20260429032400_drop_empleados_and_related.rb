class DropEmpleadosAndRelated < ActiveRecord::Migration[8.0]
  def change
    # Eliminar FK y columna empleado_id de users
    remove_foreign_key :users, :empleados
    remove_column :users, :empleado_id, :bigint

    # Eliminar tabla de detalles de pagos por empleado
    drop_table :detalle_pagos_empleados

    # Eliminar tabla de empleados
    drop_table :empleados
  end
end
