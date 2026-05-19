class AddFinalizadaToOrdenesDeCompra < ActiveRecord::Migration[8.0]
  def change
    add_column :ordenes_de_compra, :finalizada, :boolean, default: false, null: false
  end
end
