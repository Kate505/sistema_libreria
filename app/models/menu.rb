class Menu < ApplicationRecord
  self.table_name = "menus"

  belongs_to :modulo
  belongs_to :parent, class_name: "Menu", optional: true, foreign_key: "menu_id"
  has_many :submenus, class_name: "Menu", foreign_key: "menu_id", dependent: :destroy

  has_many :roles_menus
  has_many :roles, through: :roles_menus, source: :rol

  validates :codigo, presence: true, length: { maximum: 10 }, uniqueness: true
  validates :nombre, presence: true, length: { maximum: 50 }
end
