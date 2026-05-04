class Egreso < ApplicationRecord
  belongs_to :categoria_egreso

  validates :monto, presence: true, numericality: { greater_than: 0 }
  validates :categoria_egreso_id, presence: true

  before_validation :set_fecha

  scope :en_rango,     ->(desde, hasta) { where(fecha: desde..hasta) }
  scope :esta_semana,  -> { en_rango(Time.current.beginning_of_week, Time.current.end_of_week) }

  private

  def set_fecha
    self.fecha ||= Time.current
  end
end
