class CreateVentas < ActiveRecord::Migration[8.0]
  def change
    create_table :ventas do |t|
      t.references :cliente, null: true, foreign_key: true

      t.datetime :fecha_venta, default: -> { 'CURRENT_TIMESTAMP' }

      t.string :metodo_pago, limit: 50
      t.decimal :cantidad_total, precision: 10, scale: 2

      t.timestamps
    end
  end
end
