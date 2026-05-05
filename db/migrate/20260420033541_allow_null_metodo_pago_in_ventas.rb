class AllowNullMetodoPagoInVentas < ActiveRecord::Migration[8.0]
  def change
    # Permite que metodo_pago sea NULL hasta que se finalice la transacción
    change_column_null :ventas, :metodo_pago, true

    # Columna para saber si la venta fue cerrada/finalizada
    add_column :ventas, :finalizada, :boolean, default: false, null: false
  end
end
