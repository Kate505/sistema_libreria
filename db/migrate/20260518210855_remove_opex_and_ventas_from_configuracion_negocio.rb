class RemoveOpexAndVentasFromConfiguracionNegocio < ActiveRecord::Migration[8.0]
  def change
    remove_column :configuracion_negocio, :porcentaje_opex, :decimal, precision: 5, scale: 4, null: false, default: "0.2000"
    remove_column :configuracion_negocio, :ventas_proyectadas_mes, :decimal, precision: 12, scale: 2, null: false, default: "0.0"
  end
end
