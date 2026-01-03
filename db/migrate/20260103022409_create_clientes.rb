class CreateClientes < ActiveRecord::Migration[8.0]
  def change
    create_table :clientes do |t|
      t.string :primer_nombre, limit: 50
      t.string :segundo_nombre, limit: 50
      t.string :primer_apellido, limit: 50
      t.string :segundo_apellido, limit: 50
      t.string :email, limit: 100

      t.timestamps
    end
  end
end
