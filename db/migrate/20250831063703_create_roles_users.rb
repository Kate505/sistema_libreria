class CreateRolesUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :roles_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :rol, null: false, foreign_key: { to_table: :roles }

      t.timestamps
    end

    add_index :roles_users, [ :user_id, :rol_id ], unique: true, name: "roles_users_user_id_rol_id_uq"
  end
end
