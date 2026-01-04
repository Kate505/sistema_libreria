class Venta < ApplicationRecord

  self.table_name = "ventas"

  belongs_to :cliente, optional: true
  has_many :detalle_ventas, dependent: :destroy

  METODOS_PAGO = {
    "E"  => "Efectivo",
    "T"  => "Tarjeta",
    "TR" => "Transferencia"
  }.freeze

  validates :fecha_venta, presence: true

  validates :metodo_pago,
            presence: true,
            length: { maximum: 2 },
            inclusion: {
              in: METODO_PAGO.keys,
              message: "%{value} no es un método de pago válido"
            }

  validates :cantidad_total,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  normalizes :metodo_pago, with: ->(m) { m.strip.titleize }

  scope :hoy, -> { where(fecha_venta: Time.current.all_day) }
  scope :por_metodo_pago, ->(metodo) { where(metodo_pago: metodo) }
end
