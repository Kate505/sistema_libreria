class RedesignGastosOperativos < ActiveRecord::Migration[8.0]
  def change
    add_column :gastos_operativos, :fecha, :date
    add_column :gastos_operativos, :cantidad, :decimal, precision: 10, scale: 2
    add_column :gastos_operativos, :descripcion, :string, limit: 255

    # Remove unique index on periodo_mes + periodo_year
    remove_index :gastos_operativos, [:periodo_mes, :periodo_year]

    # Make old columns nullable for backward compat
    change_column_null :gastos_operativos, :periodo_mes, true
    change_column_null :gastos_operativos, :periodo_year, true
  end
end
