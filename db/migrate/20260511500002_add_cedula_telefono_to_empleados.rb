class AddCedulaTelefonoToEmpleados < ActiveRecord::Migration[8.0]
  def change
    add_column :empleados, :cedula, :string, limit: 16
    add_column :empleados, :telefono, :string, limit: 8
  end
end
