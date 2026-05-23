class AddUserToGastosOperativosAndOrdenesDeCompra < ActiveRecord::Migration[8.0]
  def change
    add_reference :gastos_operativos, :user, null: true, foreign_key: true
    add_reference :ordenes_de_compra, :user, null: true, foreign_key: true
  end
end
