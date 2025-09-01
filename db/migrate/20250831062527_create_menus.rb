class CreateMenus < ActiveRecord::Migration[8.0]
  def change
    create_table :menus do |t|
      t.string :codigo, limit: 10, null: false
      t.string :nombre, limit: 50, null: false
      t.string :icono, null: false
      t.references :modulo, null: false, foreign_key: true
      t.references :menu, foreign_key: { to_table: :menus }
      t.string :link_to, null: false
      t.boolean :pasivo, null: false, default: false

      t.timestamps
    end

    add_index :menus, :codigo, unique: true
    add_index :menus, [:codigo, :modulo_id, :menu_id], unique: true, name: "menus_codigo_modulo_id_menu_id_uq"
  end
end
