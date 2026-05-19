class Empleado < ApplicationRecord
  self.table_name = "empleados"

  has_one :user, dependent: :nullify

  before_validation :strip_cedula_dashes

  normalizes :primer_nombre, :segundo_nombre, :primer_apellido, :segundo_apellido, :cargo,
             with: ->(valor) { valor.strip.titleize }

  validates :primer_nombre, :primer_apellido,
            presence: true,
            length: { maximum: 50 }

  validates :segundo_nombre, :segundo_apellido,
            length: { maximum: 50 },
            allow_blank: true

  validates :cargo,
            length: { maximum: 100 },
            allow_blank: true

  validates :telefono,
            format: { with: /\A\d{8}\z/, message: "debe ser exactamente 8 dígitos numéricos" },
            allow_blank: true

  validates :cedula,
            uniqueness: true,
            format: { with: /\A\d{13}[A-Z]\z/, message: "debe tener formato: 000-000000-0000X (3 dígitos - 6 dígitos fecha nacimiento - 4 dígitos y 1 letra mayúscula)" },
            allow_blank: true

  validate :fecha_contratacion_no_futura

  scope :activos, -> { where(pasivo: false) }
  scope :pasivos, -> { where(pasivo: true) }

  def nombre_completo
    [ primer_nombre, segundo_nombre, primer_apellido, segundo_apellido ].compact.join(" ")
  end

  def nombre_corto
    "#{primer_nombre} #{primer_apellido}"
  end

  scope :empleados_sin_usuario, -> {
    left_outer_joins(:user).where(users: { id: nil })
  }

  scope :empleados_activos, -> { where(pasivo: false) }

  scope :por_nombre_completo, ->(nombre) {
    where(
      "primer_nombre ILIKE :q OR segundo_nombre ILIKE :q " \
        "OR primer_apellido ILIKE :q OR segundo_apellido ILIKE :q",
      q: "%#{nombre}%"
    )
  }

  # Formato con guiones para mostrar en vistas
  def cedula_formateada
    return nil if cedula.blank?
    "#{cedula[0..2]}-#{cedula[3..8]}-#{cedula[9..13]}"
  end

  private

  def strip_cedula_dashes
    self.cedula = cedula.gsub("-", "") if cedula.present?
  end

  def fecha_contratacion_no_futura
    return if fecha_contratacion.blank?

    if fecha_contratacion > Date.current
      errors.add(:fecha_contratacion, "no puede ser una fecha futura")
    end
  end
end
