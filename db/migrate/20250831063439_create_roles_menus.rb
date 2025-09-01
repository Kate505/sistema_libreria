class CreateRolesMenus < ActiveRecord::Migration[8.0]
  def change
    create_table :roles_menus do |t|
      t.references :rol, null: false, foreign_key: { to_table: :roles }
      t.references :menu, null: false, foreign_key: { to_table: :menus }

      t.timestamps
    end

    add_index :roles_menus, [ :rol_id, :menu_id ], unique: true, name: "roles_menus_rol_id_menu_id_uq"
  end
end
