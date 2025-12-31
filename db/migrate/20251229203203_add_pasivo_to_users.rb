class AddPasivoToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :pasivo, :boolean, default: false, null: false
  end
end
