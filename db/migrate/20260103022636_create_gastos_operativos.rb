class CreateGastosOperativos < ActiveRecord::Migration[8.0]
  def change
    create_table :gastos_operativos do |t|
      t.integer :periodo_mes, null: false
      t.integer :periodo_year, null: false

      t.decimal :costos_alquiler, precision: 10, scale: 2, default: 0.00
      t.decimal :costo_utilidades, precision: 10, scale: 2, default: 0.00
      t.decimal :costo_mantenimiento, precision: 10, scale: 2, default: 0.00

      t.decimal :costo_salario_total, precision: 10, scale: 2, default: 0.00
      t.decimal :gran_total_gastos, precision: 10, scale: 2

      t.timestamps
    end

    add_index :gastos_operativos, [:periodo_mes, :periodo_year], unique: true
  end
end
