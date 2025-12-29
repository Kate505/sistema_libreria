class RemoveIconoFromMenu < ActiveRecord::Migration[8.0]
  def change
    remove_column :menus, :icono, :string
  end
end
