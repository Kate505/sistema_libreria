class CreateProveedores < ActiveRecord::Migration[8.0]
  def change
    create_table :proveedores do |t|
      t.string :nombre, null: false, limit: 150
      t.string :telefono, limit: 255
      t.string :direccion, limit: 255

      t.timestamps
    end
  end
end
