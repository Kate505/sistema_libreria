class CreateEgresosSystem < ActiveRecord::Migration[8.0]
  def change
    # Eliminar tabla antigua de gastos operativos por período
    drop_table :gastos_operativos, if_exists: true

    # Tabla de categorías de egresos (gestionada en la misma pantalla)
    create_table :categoria_egresos do |t|
      t.string  :nombre,      null: false, limit: 100
      t.string  :descripcion, limit: 255
      t.timestamps
    end
    add_index :categoria_egresos, :nombre, unique: true

    # Tabla de egresos individuales
    create_table :egresos do |t|
      t.references :categoria_egreso, null: false, foreign_key: true
      t.decimal    :monto,       precision: 10, scale: 2, null: false
      t.string     :descripcion, limit: 255
      t.string     :comprobante, limit: 100
      t.datetime   :fecha,       null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.timestamps
    end

    # Categorías por defecto
    reversible do |dir|
      dir.up do
        execute <<-SQL
          INSERT INTO categoria_egresos (nombre, created_at, updated_at)
          VALUES
            ('Servicios',     NOW(), NOW()),
            ('Limpieza',      NOW(), NOW()),
            ('Mantenimiento', NOW(), NOW()),
            ('Otros',         NOW(), NOW())
        SQL
      end
    end
  end
end
