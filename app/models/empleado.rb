class Empleado < ApplicationRecord

  self.table_name = "empleados"

  has_one :user, dependent: :nullify

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

  validates :salario_base,
            presence: true,
            numericality: { greater_than: 0 }

  validates :viatico_transporte,
            numericality: { greater_than_or_equal_to: 0 }

  scope :activos, -> { where(pasivo: false) }
  scope :pasivos, -> { where(pasivo: true) }

  def nombre_completo
    [primer_nombre, segundo_nombre, primer_apellido, segundo_apellido].compact.join(' ')
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

end
