class AddTasaCambioToConfiguracionNegocio < ActiveRecord::Migration[8.0]
  def change
    add_column :configuracion_negocio, :tasa_cambio, :decimal, precision: 8, scale: 2, null: false, default: 36.70
  end
end
