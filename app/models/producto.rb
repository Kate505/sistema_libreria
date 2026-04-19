class Producto < ApplicationRecord
  self.table_name = "productos"

  belongs_to :categoria, foreign_key: "categoria_id"
  belongs_to :marca, optional: true
  has_many :detalle_ordenes_de_compra
  has_many :detalle_ventas

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

  validates :stock_actual,
            :precio_venta,
            :precio_venta_al_mayor,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

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

  # Precio de venta sugerido basado en el CPP actual y la configuración global.
  # Fórmula: CPP / (1 - (% Ganancia + % OpEx))
  def precio_sugerido
    return nil if costo_promedio_ponderado.to_d <= 0

    ConfiguracionNegocio.configuracion.precio_sugerido(costo_promedio_ponderado)
  end

  # Margen de ganancia neta estimado al precio de venta actual.
  # Retorna un decimal (ej: 0.40 = 40%)
  def margen_estimado
    pv    = precio_venta.to_d
    costo = costo_promedio_ponderado.to_d
    return BigDecimal("0") if pv <= 0

    ConfiguracionNegocio.configuracion.margen_actual(pv, costo)
  end

  # Retorna true si el margen neta actual está por debajo del umbral de alerta.
  def margen_bajo?
    umbral = ConfiguracionNegocio.configuracion.margen_alerta_minimo.to_d
    margen_estimado < umbral
  end

  # ─── Callbacks de compras ────────────────────────────────────────────

  # Llamado después de crear un DetalleOrdenDeCompra.
  # Incrementa stock, actualiza último precio de compra, recalcula CPP
  # y actualiza precio_venta con el precio sugerido por la configuración.
  def actualizar_por_compra!(detalle)
    transaction do
      cantidad   = detalle.cantidad.to_i
      precio     = detalle.precio_unitario_compra.to_d
      costo      = detalle.costo_unitario_compra_calculado.to_d
      stock_prev = stock_actual.to_i

      nuevo_stock = stock_prev + cantidad

      nuevo_cpp = if nuevo_stock > 0
                    ((costo_promedio_ponderado.to_d * stock_prev) + (costo * cantidad)) / nuevo_stock
      else
                    costo
      end

      nuevo_cpp_redondeado = nuevo_cpp.round(4)

      # Calcular precio sugerido con el nuevo CPP
      nuevo_precio_sugerido = ConfiguracionNegocio.configuracion
                                                  .precio_sugerido(nuevo_cpp_redondeado)

      columnas = {
        stock_actual:             nuevo_stock,
        ultimo_precio_compra:     precio,
        costo_promedio_ponderado: nuevo_cpp_redondeado
      }
      # Actualizar precio_venta con el precio sugerido (el usuario puede modificarlo)
      columnas[:precio_venta] = nuevo_precio_sugerido if nuevo_precio_sugerido&.positive?

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
