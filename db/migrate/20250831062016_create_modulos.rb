class CreateModulos < ActiveRecord::Migration[8.0]
  def change
    create_table :modulos do |t|
      t.string :nombre, limit: 50, null: false
      t.string :icono, null: false
      t.string :link_to, null: false
      t.boolean :pasivo, null: false, default: false

      t.timestamps
    end

    add_index :modulos, :nombre, unique: true
  end
end
