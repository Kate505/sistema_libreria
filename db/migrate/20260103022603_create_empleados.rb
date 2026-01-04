class CreateEmpleados < ActiveRecord::Migration[8.0]
  def change
    create_table :empleados do |t|
      t.string :primer_nombre, null: false, limit: 50
      t.string :segundo_nombre, limit: 50
      t.string :primer_apellido, null: false, limit: 50
      t.string :segundo_apellido, limit: 50

      t.string :cargo, limit: 100

      t.decimal :salario_base, precision: 10, scale: 2, null: false
      t.decimal :viatico_transporte, precision: 10, scale: 2, default: 0.00

      t.date :fecha_contratacion
      t.boolean :pasivo, default: false

      t.timestamps
    end
  end
end
