class AddUserToVentas < ActiveRecord::Migration[8.0]
  def change
    add_reference :ventas, :user, null: true, foreign_key: true, index: true
  end
end

