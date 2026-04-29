class DropCostoSalarioTotalFromGastosOperativos < ActiveRecord::Migration[8.0]
  def change
    remove_column :gastos_operativos, :costo_salario_total, :decimal
  end
end
