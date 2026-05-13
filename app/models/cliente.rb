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

  validates :telefono,
            format: { with: /\A\d{8}\z/, message: "debe ser exactamente 8 dígitos numéricos" },
            allow_blank: true

  validates :cedula,
            uniqueness: true,
            format: { with: /\A\d{3}-\d{6}-\d{4}[A-Z]\z/, message: "debe tener formato: 000-000000-0000X (3 dígitos - 6 dígitos fecha nacimiento - 4 dígitos y 1 letra mayúscula)" },
            allow_blank: true
end
