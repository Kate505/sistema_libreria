class AddPasivoToProductos < ActiveRecord::Migration[8.0]
  def change
    add_column :productos, :pasivo, :boolean, null: false, default: false
  end
end
