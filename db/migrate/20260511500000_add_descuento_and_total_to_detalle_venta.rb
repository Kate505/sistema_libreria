class AddDescuentoAndTotalToDetalleVenta < ActiveRecord::Migration[8.0]
  def change
    add_column :detalle_venta, :descuento_porcentaje, :integer, default: 0, null: false
    add_column :detalle_venta, :total_linea, :decimal, precision: 10, scale: 2
  end
end
