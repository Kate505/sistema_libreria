# Servicio reutilizable para calcular el precio de venta sugerido de un producto.
#
# Fórmula base:
#   precio_nuevo = costo_unitario / (1 - margen_ganancia_meta)
#
# Si el producto ya tiene un precio distinto al calculado:
#   precio_final = ceil((precio_nuevo + precio_venta_actual) / 2)
#
# Siempre se redondea al entero superior (ceil).
#
# Uso:
#   PriceCalculationService.call(producto, costo_unitario)
#   PriceCalculationService.call(producto, costo_unitario, config: config_personalizada)
#
class PriceCalculationService
  def self.call(producto, costo_unitario, config: nil)
    new(producto, costo_unitario, config: config).call
  end

  def initialize(producto, costo_unitario, config: nil)
    @producto       = producto
    @costo_unitario = costo_unitario.to_d
    @config         = config || ConfiguracionNegocio.configuracion
  end

  def call
    return 0 if @costo_unitario <= 0

    precio_nuevo = calcular_precio_base
    return precio_nuevo unless @producto.precio_venta.to_d.positive?
    return precio_nuevo if @producto.precio_venta.to_i.eql?(precio_nuevo)

    promediar_con_precio_actual(precio_nuevo)
  end

  private

  # Fórmula: costo / (1 - margen), redondeado al entero superior
  def calcular_precio_base
    denominador = 1.0 + @config.margen_ganancia_meta.to_d

    (@costo_unitario * denominador).ceil
  end

  # Promedio entre precio nuevo y actual, redondeado al entero superior
  def promediar_con_precio_actual(precio_nuevo)
    ((precio_nuevo + @producto.precio_venta.to_d) / 2).ceil
  end
end
