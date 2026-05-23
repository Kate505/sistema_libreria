class GastoOperativo < ApplicationRecord
  self.table_name = "gastos_operativos"

  belongs_to :user, optional: true

  validates :fecha, presence: true
  validates :cantidad, presence: true, numericality: { greater_than: 0 }
  validates :descripcion, presence: true, length: { maximum: 255 }

  validate :fecha_no_futura

  before_save :sincronizar_campos_legados
  before_update :prevent_update

  scope :por_fecha_desc, -> { order(fecha: :desc) }

  scope :buscar, ->(q) {
    return all if q.blank?
    where("descripcion ILIKE ?", "%#{q}%")
  }

  scope :por_rango_fecha, ->(desde, hasta) {
    scope = all
    scope = scope.where("fecha >= ?", desde.to_date) if desde.present?
    scope = scope.where("fecha <= ?", hasta.to_date) if hasta.present?
    scope
  }

  def periodo_legible
    return "" if periodo_mes.blank? || periodo_year.blank?
    nombre_mes = I18n.t("date.month_names")[periodo_mes]
    "#{nombre_mes.capitalize} #{periodo_year}"
  end

  private

  def fecha_no_futura
    return if fecha.blank?
    errors.add(:fecha, "no puede ser una fecha futura") if fecha > Date.current
  end

  # Mantener campos legados sincronizados por si reportes viejos los usan
  def sincronizar_campos_legados
    if fecha.present?
      self.periodo_mes  = fecha.month
      self.periodo_year = fecha.year
    end
    self.gran_total_gastos = cantidad
    self.costos_alquiler      ||= 0
    self.costo_utilidades     ||= 0
    self.costo_mantenimiento  ||= 0
  end

  def prevent_update
    errors.add(:base, "Los gastos operativos no se pueden modificar.")
    throw(:abort)
  end
end
