class Cliente < ApplicationRecord
  self.table_name = "clientes"

  before_validation :strip_cedula_dashes

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
            format: { with: /\A\d{13}[A-Z]\z/, message: "debe tener formato: 000-000000-0000X (3 dígitos - 6 dígitos fecha nacimiento - 4 dígitos y 1 letra mayúscula)" },
            allow_blank: true

  # Formato con guiones para mostrar en vistas
  def cedula_formateada
    return nil if cedula.blank?
    "#{cedula[0..2]}-#{cedula[3..8]}-#{cedula[9..13]}"
  end

  private

  def strip_cedula_dashes
    self.cedula = cedula.gsub("-", "") if cedula.present?
  end
end
