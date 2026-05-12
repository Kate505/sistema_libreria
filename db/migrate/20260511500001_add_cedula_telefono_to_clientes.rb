class AddCedulaTelefonoToClientes < ActiveRecord::Migration[8.0]
  def change
    add_column :clientes, :cedula, :string, limit: 16
    add_column :clientes, :telefono, :string, limit: 8
  end
end
