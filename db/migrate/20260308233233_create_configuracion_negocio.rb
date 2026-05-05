class CreateConfiguracionNegocio < ActiveRecord::Migration[8.0]
  def change
    create_table :configuracion_negocio do |t|
      # 40% de ganancia neta meta (expresado como decimal, ej: 0.40)
      t.decimal :margen_ganancia_meta,   precision: 5, scale: 4, null: false, default: "0.4000"
      # % estimado de gastos operativos fijos (alquiler + salario) sobre ventas
      t.decimal :porcentaje_opex,        precision: 5, scale: 4, null: false, default: "0.2000"
      # Ventas totales proyectadas por mes (para referencia de sugerencia)
      t.decimal :ventas_proyectadas_mes, precision: 12, scale: 2, null: false, default: "0.0"
      # Si el margen real baja de este umbral, se muestra alerta en la tabla de productos
      t.decimal :margen_alerta_minimo,   precision: 5, scale: 4, null: false, default: "0.3500"

      t.timestamps
    end
  end
end
