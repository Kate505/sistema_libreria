class CreateDetalleOrdenesDeCompra < ActiveRecord::Migration[8.0]
  def change
    create_table :detalle_ordenes_de_compra do |t|
      t.references :orden_de_compra, null: false, foreign_key: true
      t.references :producto, null: false, foreign_key: true

      t.integer :cantidad, null: false

      t.decimal :precio_unitario_compra, precision: 10, scale: 2, null: false
      t.decimal :costo_unitario_compra_calculado, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
