# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, "\\1en"
#   inflect.singular /^(ox)en/i, "\\1"
#   inflect.irregular "person", "people"
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular 'venta', 'ventas'
  inflect.irregular 'detalle_venta', 'detalle_ventas'
  inflect.irregular 'gasto_operativo', 'gastos_operativos'
  inflect.irregular 'detalle_pago', 'detalle_pagos'
  inflect.irregular 'detalle_pago_empleado', 'detalle_pagos_empleados'
  inflect.irregular 'empleado', 'empleados'
  inflect.irregular 'proveedor', 'proveedores'
  inflect.irregular 'orden_de_compra', 'ordenes_de_compra'
  inflect.irregular 'detalle_orden_de_compra', 'detalle_ordenes_de_compra'
end
