class CreateMarcas < ActiveRecord::Migration[8.0]
  def change
    create_table :marcas do |t|
      t.string :nombre, null: false
      t.timestamps
    end

    add_reference :productos, :marca, foreign_key: true
  end
end
