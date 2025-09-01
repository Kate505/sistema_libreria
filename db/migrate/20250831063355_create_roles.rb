class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles do |t|
      t.string :nombre, null: false
      t.boolean :pasivo, null: false, default: false

      t.timestamps
    end
  end
end
