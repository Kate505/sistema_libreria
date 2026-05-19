class AllowNullPreciosInProductos < ActiveRecord::Migration[8.0]
  def change
    change_column_null :productos, :precio_venta, true
    change_column_null :productos, :precio_venta_al_mayor, true
  end
end
