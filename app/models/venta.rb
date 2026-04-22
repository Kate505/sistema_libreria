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

  # metodo_pago es opcional al crear la venta. Se valida solo si está presente
  # (se registra al finalizar la transacción).
  validates :metodo_pago,
            length: { maximum: 2 },
            inclusion: {
              in: METODOS_PAGO.keys,
              message: "%{value} no es un método de pago válido"
            },
            allow_blank: true

  # cantidad_total es CALCULADO automáticamente por DetalleVenta callbacks.
  # NO debe validarse como presencia porque al crear una nueva venta siempre
  # empieza en nil/0 antes de agregar productos.
  validates :cantidad_total,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  normalizes :metodo_pago, with: -> (m) { m.present? ? m.strip.upcase : m }

  # Garantiza que cantidad_total nunca sea nil en BD al guardar
  before_validation :inicializar_cantidad_total

  scope :hoy,             -> { where(fecha_venta: Time.current.all_day) }
  scope :por_metodo_pago, -> (metodo) { where(metodo_pago: metodo) }
  scope :ultimos_n_meses, -> (n) { where("fecha_venta >= ?", n.months.ago.beginning_of_month) }
  scope :pendientes,      -> { where(finalizada: false) }
  scope :finalizadas,     -> { where(finalizada: true) }

  def pendiente?
    !finalizada?
  end

  private

  def inicializar_cantidad_total
    self.cantidad_total ||= 0
  end
end
