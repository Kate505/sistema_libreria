class CategoriaEgreso < ApplicationRecord
  has_many :egresos, dependent: :restrict_with_error

  validates :nombre, presence: true, uniqueness: true, length: { maximum: 100 }
  validates :descripcion, length: { maximum: 255 }, allow_blank: true
end
