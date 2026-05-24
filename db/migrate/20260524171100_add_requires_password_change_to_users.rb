class AddRequiresPasswordChangeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :requires_password_change, :boolean, default: false, null: false
  end
end
