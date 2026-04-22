require 'roo'

# Limpiar tablas para que el seed sea re-ejecutable sin conflictos
Session.delete_all
RolesUser.delete_all
RolesMenu.delete_all
Menu.delete_all
Modulo.delete_all
Rol.delete_all
User.delete_all
Empleado.delete_all

# Limpiar inventario y catálogos relacionados (en orden correcto por FK)
DetalleVenta.delete_all
Venta.delete_all
DetalleOrdenDeCompra.delete_all
OrdenDeCompra.delete_all
Producto.delete_all
Marca.delete_all
Categoria.delete_all
Proveedor.delete_all


# -------------  Módulos  ------------- #

modulo_facturacion = Modulo.create!(nombre: "Facturación", icono: "facturacion.svg", link_to: "/facturacion")
modulo_inventario = Modulo.create!(nombre: "Inventario", icono: "inventario.svg", link_to: "/inventario")
modulo_catalogos = Modulo.create!(nombre: "Catálogos", icono: "catalogos.svg", link_to: "/catalogos")
modulo_estadisticas = Modulo.create!(nombre: "Estadísticas", icono: "estadisticas.svg", link_to: "/estadisticas")
modulo_finanzas = Modulo.create!(nombre: "Finanzas", icono: "finanzas.svg", link_to: "/finanzas")
modulo_seguridad = Modulo.create!(nombre: "Gestión de Seguridad", icono: "seguridad.svg", link_to: "/seguridad")
modulo_configuraciones = Modulo.create!(nombre: "Configuraciones", icono: "seguridad.svg", link_to: "/configuraciones")

# -------------  Menús  ------------- #

# # Módulo Facturación
menu_ventas = Menu.create!(codigo: "VENTAS", nombre: "Ventas", modulo: modulo_facturacion, link_to: "/facturacion/ventas")
menu_ventas = Menu.create!(codigo: "HISTORIAL", nombre: "Historial de Ventas", modulo: modulo_facturacion, link_to: "	/facturacion/ventas/historial")

# # Módulo Inventario
Menu.create!(codigo: "PRODUCTOS", nombre: "Inventario de Productos", modulo: modulo_inventario, link_to: "/inventario/productos")
menu_consulta_precios = Menu.create!(codigo: "CONSULTA_PRECIOS", nombre: "Consulta de Precios", modulo: modulo_inventario, link_to: "/inventario/productos/consulta_precios")
Menu.create!(codigo: "ORDENES_DE_COMPRA", nombre: "Órdenes de Abastecimiento", modulo: modulo_inventario, link_to: "/inventario/ordenes_de_compra")

# # Módulo Catálogos
Menu.create!(codigo: "CATEGORIAS", nombre: "Categorías de Productos", modulo: modulo_catalogos, link_to: "/catalogos/categorias")
Menu.create!(codigo: "PROVEEDORES", nombre: "Proveedores", modulo: modulo_catalogos, link_to: "/catalogos/proveedores")
menu_clientes = Menu.create!(codigo: "CLIENTES", nombre: "Clientes", modulo: modulo_catalogos, link_to: "/catalogos/clientes")

# # Módulo Estadísticas
Menu.create!(codigo: "ESTADISTICAS", nombre: "Estadísticas por período", modulo: modulo_estadisticas, link_to: "/estadisticas/estadisticas_periodo")

# # Módulo Finanzas
Menu.create!(codigo: "GASTOS_OPERATIVOS", nombre: "Gastos Operativos", modulo: modulo_finanzas, link_to: "/finanzas/gastos_operativos")
Menu.create!(codigo: "DETALLE_PAGOS_EMPLEADOS", nombre: "Nómina Empleados", modulo: modulo_finanzas, link_to: "/finanzas/nomina_empleados")

# # Módulo Configuraciones
Menu.create!(codigo: "NEGOCIO", nombre: "Configuración de Negocio", modulo: modulo_configuraciones, link_to: "/configuraciones/negocio/edit")

# # Módulo Gestión de Seguridad
Menu.create!(codigo: "MODULOS", nombre: "Módulos", modulo: modulo_seguridad, link_to: "/seguridad/modulos")
Menu.create!(codigo: "MENUS", nombre: "Menús", modulo: modulo_seguridad, link_to: "/seguridad/menus")
Menu.create!(codigo: "USUARIOS", nombre: "Usuarios", modulo: modulo_seguridad, link_to: "/seguridad/usuarios")
Menu.create!(codigo: "EMPLEADOS", nombre: "Empleados", modulo: modulo_seguridad, link_to: "/seguridad/empleados")

menu_padre_gestion_roles = Menu.create!(codigo: "SM001", nombre: "Gestión de Roles", modulo: modulo_seguridad, link_to: "/seguridad/roles")
Menu.create!(codigo: "ROLES", nombre: "Roles", modulo: modulo_seguridad, parent: menu_padre_gestion_roles, link_to: "/seguridad/roles")

# -------------  Roles y Usuarios  ------------- #
# Empleados

empleado_admin = Empleado.create!(primer_nombre: "Administrador", primer_apellido: "Sistema", cargo: "Administrador", salario_base: 7000, viatico_transporte: 0)
empleado_usuario = Empleado.create!(primer_nombre: "Usuario", primer_apellido: "Sistema", cargo: "Usuario", salario_base: 5000, viatico_transporte: 0)

# Usuarios
user_admin = User.create!(email_address: "admin@gmail.com", password: "123456", password_confirmation: "123456", empleado: empleado_admin)
user_normal = User.create!(email_address: "user@gmail.com", password: "123456", password_confirmation: "123456", empleado: empleado_usuario)

# Roles
admin_role = Rol.create!(nombre: "Administrador")
seller_role = Rol.create!(nombre: "Vendedor")

# Roles - Menús
Menu.all.each do |menu|
  RolesMenu.create!(rol: admin_role, menu: menu)
end

[ menu_ventas, menu_clientes, menu_consulta_precios ].each do |menu|
  RolesMenu.create!(rol: seller_role, menu: menu)
end

# Roles - Usuarios
RolesUser.create!(user: user_admin, rol: admin_role)
RolesUser.create!(user: user_normal, rol: seller_role)

# -----------------------------

# CARGA INTELIGENTE DE INVENTARIO

# -----------------------------

puts "Cargando inventario desde Excel..."

file = Rails.root.join('db', 'inventario.csv')
# Use Roo::CSV instead, and convert the Pathname to a string
sheet = Roo::CSV.new(file.to_s)

# Note: You don't need `sheet = xlsx.sheet(0)` anymore because
# a CSV is inherently just a single sheet. The `sheet` variable
# now holds the parsed CSV data directly.`

headers = sheet.row(1).map { |h| h.to_s.strip }

# Proveedor genérico para inventario inicial

proveedor = Proveedor.find_or_create_by!(nombre: "Proveedor Inicial Inventario") do |p|
  p.telefono = "88888888"     # 8 caracteres sin guion (límite del modelo)
  p.direccion = "Ciudad"       # Example field
end

# Crear orden de compra inicial

orden = OrdenDeCompra.create!(
  proveedor: proveedor,
  fecha_compra: Date.today,
  numero_factura: "INVENTARIO-INICIAL",
  costo_total_flete: 0
)

# Categoría base

def detectar_categoria(nombre)
  # Normalizamos para que funcione con MAYÚSCULAS, acentos ("lápices") y búsquedas en cualquier parte del texto.
  t = I18n.transliterate(nombre.to_s).downcase

  # Traemos categorías existentes para evitar crear categorías nuevas por un typo del clasificador.
  # Si no existen (BD vacía), devolvemos el string calculado como antes.
  categorias_existentes = Categoria.pluck(:nombre)
  pick = lambda do |preferida, fallback|
    return preferida if categorias_existentes.include?(preferida)
    return fallback if fallback && categorias_existentes.include?(fallback)
    preferida
  end

  # Regex utilitarias
  re_colores = /\bcolor(?:es)?\b/
  re_papeleria = /\b(?:hojas?|papel|cartulina|papelografo|folder|carpeta|cuaderno|libreta|block)\b/
  re_instrumento_escritura = /\b(?:lapic(?:er)?o(?:s)?|lapiz(?:ces)?|pluma(?:s)?|boligrafo(?:s)?|esfero(?:s)?|portamin(?:a|as)|lapicera(?:s)?|marcador(?:es)?|resaltador(?:es)?)\b/

  # Regla inteligente de "colores":
  # - "lapiceros/marcadores/... de colores" => Lapices y Lapiceros
  # - "colores" suelto => Lapices de colores
  # EXCEPTO: si habla de papelería (papel/cartulina/etc.), se va a Papelería.
  if t.match?(re_colores)
    if t.match?(re_papeleria)
      return pick.call("Papelería", "Papeleria")
    end

    if t.match?(re_instrumento_escritura)
      return pick.call("Lapices y Lapiceros", nil)
    end

    return pick.call("Lapices de colores", "Lapices y Lapiceros")
  end

  case t
  when /tajador|borrador/
    pick.call("Tajadores y Borradores", nil)

  when /lapiz|lapicero|lapiceros|pluma|boligrafo|esfero|portamin|lapicera/
    pick.call("Lapices y Lapiceros", nil)

  when /corrector|mina|minas/
    pick.call("Correctores y minas", nil)

  when /tape|sellador|pega|silicon/
    pick.call("Pegas, silicones y cintas", nil)

  when /tijera|cutter/
    pick.call("Tijeras y cutter", nil)

  when /tachuelas|pushpin|chinches/
    pick.call("Tachuelas y chinches", nil)

  when /notitas|notas/
    pick.call("Notitas", nil)

  when /marcador|marcadores|resaltador|resaltadores/
    pick.call("Marcadores", nil)

  when /cuaderno|libreta|block/
    pick.call("Cuadernos y libretas", nil)

  when /folder|carpeta/
    pick.call("Folders y Carpetas", nil)

  when /foami/
    pick.call("Foamis", nil)

  when /hojas|papel|cartulina|papelografo/
    pick.call("Papelería", "Papeleria")

  when /regla|geometrico/
    pick.call("Geometría", "Geometria")
  else
    pick.call("Otros", nil)
  end
end

(2..sheet.last_row).each_with_index do |i, index|

  row = Hash[[headers, sheet.row(i)].transpose]

  nombre = row["Nombre"].to_s.strip
  next if nombre.blank?

  marca_nombre = row["Marca"].to_s.strip
  marca_nombre = "Sin Marca" if marca_nombre.blank?

  marca = Marca.find_or_create_by!(nombre: marca_nombre)

  categoria_nombre = detectar_categoria(nombre)
  categoria = Categoria.find_or_create_by!(nombre: categoria_nombre)

  cantidad = row["Cantidad"].to_i

  precio_compra = row["Precio unitario de compra"].to_f
  precio_compra = precio_venta * 0.60 if precio_compra.nil?

  precio_venta = row["Precio unitario de venta"].to_f
  precio_venta = 0 if precio_venta.nil?

  precio_mayor =
    row["Precio por mayor de venta"].present? ?
      row["Precio por mayor de venta"].to_f :
      precio_venta

  sku = "#{categoria.nombre[0..2].upcase}-#{marca.nombre[0..2].upcase}-#{index.to_s.rjust(5,'0')}"

  producto = Producto.create!(
    categoria: categoria,
    marca: marca,
    nombre: nombre,
    sku: sku,
    stock_actual: cantidad,
    precio_venta: precio_venta,
    precio_venta_al_mayor: precio_mayor,
    ultimo_precio_compra: precio_compra,
    costo_promedio_ponderado: precio_compra,
    descuento: false,
    descuento_maximo: 0,
    stock_minimo_limite: 2,
    stock_maximo_limite: 500
  )

  begin
    # Crear detalle de orden de compra inicial
    DetalleOrdenDeCompra.create!(
      orden_de_compra: orden,
      producto: producto,
      cantidad: cantidad,
      precio_unitario_compra: precio_compra,
      costo_unitario_compra_calculado: precio_compra
    )
  rescue ActiveRecord::RecordInvalid => e
    puts "Error in Row #{i}: #{e.message}"
    puts "Data causing error: Producto: #{producto.nombre}, Cantidad: #{cantidad}, Precio Compra: #{precio_compra}"
    # If you want the script to STOP immediately when it finds an error, leave the next line uncommented:
    raise e
  end

end

puts "Inventario cargado correctamente"
puts "Productos creados: #{Producto.count}"
puts "Marcas creadas: #{Marca.count}"
puts "Categorías creadas: #{Categoria.count}"
