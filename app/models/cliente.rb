class Cliente < ApplicationRecord
  self.table_name = "clientes"

  validates :primer_nombre,
            :primer_apellido,
            presence: true,
            length: { maximum: 50 }

  validates :segundo_nombre,
            :segundo_apellido,
            length: { maximum: 50 },
            allow_blank: true

  validates :email,
            length: { maximum: 100 }
end
