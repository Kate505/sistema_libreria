class CreateOrdenesDeCompra < ActiveRecord::Migration[8.0]
  def change
    create_table :ordenes_de_compra do |t|
      t.references :proveedor, null: false, foreign_key: true

      t.date :fecha_compra, null: false
      t.string :numero_factura, limit: 50

      t.decimal :costo_total_flete, precision: 10, scale: 2, default: 0.00

      t.timestamps
    end
  end
end
