class Producto < ApplicationRecord
  self.table_name = "productos"

  belongs_to :categoria, foreign_key: "categoria_id"
  belongs_to :marca, optional: true
  has_many :detalle_ordenes_de_compra
  has_many :detalle_ventas

  # Último detalle de compra (para mostrar costos en tabla de productos)
  has_one :ultimo_detalle_compra, -> { order(created_at: :desc) },
          class_name: "DetalleOrdenDeCompra"

  validates :sku,
            length: { maximum: 50 },
            uniqueness: true

  validates :nombre,
            presence: true,
            length: { maximum: 200 }

  validates :categoria_id,
            presence: true

  validates :descuento_maximo,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
            if: :descuento

  validates :precio_venta,
            :precio_venta_al_mayor,
            numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true

  validates :stock_actual,
            numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  validates :stock_minimo_limite,
            :stock_maximo_limite,
            numericality: { greater_than_or_equal_to: 1 }

  # Virtual attribute for handling brand creation
  def nombre_marca
    marca&.nombre
  end

  def nombre_marca=(nombre)
    if nombre.present?
      self.marca = Marca.find_or_create_by(nombre: nombre.strip)
    else
      self.marca = nil
    end
  end

  # ─── Lógica de Precios ───────────────────────────────────────────────

  # Último costo unitario calculado (con flete incluido) del detalle de compra más reciente.
  def ultimo_costo_calculado
    ultimo_detalle_compra&.costo_unitario_compra_calculado.to_d
  end

  # Margen de ganancia: porcentaje de diferencia entre precio_venta y último costo calculado.
  # Fórmula: ((PV - costo) / costo) * 100
  def margen_estimado
    pv    = precio_venta.to_d
    costo = ultimo_costo_calculado
    return BigDecimal("0") if pv <= 0 || costo <= 0

    ((pv - costo) / costo * 100).round(1)
  end

  # Retorna true si el margen actual está por debajo del umbral de alerta.
  def margen_bajo?
    umbral = (ConfiguracionNegocio.configuracion.margen_alerta_minimo.to_d * 100).round(1)
    margen_estimado < umbral
  end

  # ─── Callbacks de compras ────────────────────────────────────────────

  # Llamado después de crear un DetalleOrdenDeCompra.
  # Incrementa stock, actualiza último precio de compra, recalcula CPP (para estadísticas),
  # y calcula precio_venta con PriceCalculationService basado en el costo calculado del detalle.
  # precio_venta y precio_venta_al_mayor se mantienen sincronizados.
  def actualizar_por_compra!(detalle)
    transaction do
      cantidad   = detalle.cantidad.to_i
      costo      = detalle.costo_unitario_compra_calculado.to_d
      precio     = detalle.precio_unitario_compra.to_d
      stock_prev = stock_actual.to_i

      nuevo_stock = stock_prev + cantidad

      # CPP se mantiene para cálculos de estadísticas (COGS, valor inventario)
      nuevo_cpp = if nuevo_stock > 0
                    ((costo_promedio_ponderado.to_d * stock_prev) + (costo * cantidad)) / nuevo_stock
      else
                    costo
      end

      # Calcular precio sugerido usando el costo calculado del detalle (no CPP)
      nuevo_precio = PriceCalculationService.call(self, costo)

      columnas = {
        stock_actual:             nuevo_stock,
        ultimo_precio_compra:     precio,
        costo_promedio_ponderado: nuevo_cpp.round(4)
      }

      if nuevo_precio.positive?
        columnas[:precio_venta]          = nuevo_precio
        columnas[:precio_venta_al_mayor] = nuevo_precio
      end

      update_columns(columnas)
    end
  end

  # Llamado después de destruir un DetalleOrdenDeCompra.
  # Revierte el stock (mínimo 0). No revierte CPP ni último precio (conservador).
  def revertir_compra!(detalle)
    cantidad    = detalle.cantidad.to_i
    nuevo_stock = [ stock_actual.to_i - cantidad, 0 ].max
    update_column(:stock_actual, nuevo_stock)
  end

  # Llamado después de crear un DetalleVenta.
  # Descuenta stock (nunca baja de 0, aunque ya fue validado antes de crear).
  def vender!(cantidad)
    nuevo_stock = [ stock_actual.to_i - cantidad.to_i, 0 ].max
    update_column(:stock_actual, nuevo_stock)
  end

  # Llamado después de destruir un DetalleVenta.
  # Restaura el stock que fue descontado al momento de la venta.
  def revertir_venta!(cantidad)
    update_column(:stock_actual, stock_actual.to_i + cantidad.to_i)
  end
end
