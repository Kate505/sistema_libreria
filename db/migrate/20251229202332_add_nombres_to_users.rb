class AddNombresToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :primer_nombre, :string, null: false, default: ""
    add_column :users, :primer_apellido, :string, null: false, default: ""
    add_column :users, :segundo_nombre, :string
    add_column :users, :segundo_apellido, :string
  end
end
