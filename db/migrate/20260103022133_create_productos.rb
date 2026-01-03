class CreateProductos < ActiveRecord::Migration[8.0]
  def change
    create_table :productos do |t|
      t.references :categorias, null: false, foreign_key: true

      t.string :sku, limit: 50
      t.string :nombre, null: false, limit: 200

      t.boolean :descuento, null: false, default: false
      t.integer :descuento_maximo, default: 0

      t.integer :stock_actual, default: 0
      t.integer :stock_minimo_limite, default: 1
      t.integer :stock_maximo_limite, default: 1

      t.decimal :costo_promedio_ponderado, precision: 10, scale: 2, default: 0.00
      t.decimal :ultimo_precio_compra, precision: 10, scale: 2
      t.decimal :precio_venta, precision: 10, scale: 2, null: false
      t.decimal :precio_venta_al_mayor, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :productos, :sku, unique: true
  end
end
