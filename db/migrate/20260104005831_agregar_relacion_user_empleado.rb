class AgregarRelacionUserEmpleado < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :empleado, null: false, foreign_key: true, index: { unique: true }
  end
end
