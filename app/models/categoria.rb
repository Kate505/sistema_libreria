class Categoria < ApplicationRecord
  self.table_name = "categorias"

  has_many :productos

  validates :nombre,
            presence: true,
            length: { maximum: 50 }

end
