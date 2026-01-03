class CreateDetalleVenta < ActiveRecord::Migration[8.0]
  def change
    create_table :detalle_venta do |t|
      t.references :venta, null: false, foreign_key: true
      t.references :producto, null: false, foreign_key: true

      t.integer :cantidad, null: false

      t.decimal :precio_unitario_venta, precision: 10, scale: 2, null: false

      t.decimal :precio_historico_al_momento_de_venta, precision: 10, scale: 2

      t.timestamps
    end
  end
end
