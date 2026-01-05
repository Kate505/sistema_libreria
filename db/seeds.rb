Session.delete_all
RolesUser.delete_all
RolesMenu.delete_all
Menu.delete_all
Modulo.delete_all
Rol.delete_all
User.delete_all


# -------------  Módulos  ------------- #

modulo_facturacion = Modulo.create!(nombre: "Facturación", icono: "facturacion.svg", link_to: "/facturacion")
modulo_inventario = Modulo.create!(nombre: "Inventario", icono: "inventario.svg", link_to: "/inventario")
modulo_catalogos = Modulo.create!(nombre: "Catálogos", icono: "catalogos.svg", link_to: "/catalogos")
modulo_estadisticas = Modulo.create!(nombre: "Estadísticas", icono: "estadisticas.svg", link_to: "/estadisticas")
modulo_finanzas = Modulo.create!(nombre: "Finanzas", icono: "finanzas.svg", link_to: "/finanzas")
modulo_seguridad = Modulo.create!(nombre: "Gestión de Seguridad", icono: "seguridad.svg", link_to: "/seguridad")

# -------------  Menús  ------------- #

# # Módulo Facturación
menu_ventas = Menu.create!(codigo: "VENTAS", nombre: "Ventas", modulo: modulo_facturacion, link_to: "/facturacion/ventas")

# # Módulo Inventario
menu_inventario = Menu.create!(codigo: "PRODUCTOS", nombre: "Inventario de Productos", modulo: modulo_inventario, link_to: "/inventario/productos")

# # Módulo Catálogos
Menu.create!(codigo: "CATEGORIAS", nombre: "Categorías de Productos", modulo: modulo_catalogos, link_to: "/catalogos/categorias")
Menu.create!(codigo: "PROVEEDORES", nombre: "Proveedores", modulo: modulo_catalogos, link_to: "/catalogos/proveedores")
menu_clientes = Menu.create!(codigo: "CLIENTES", nombre: "Clientes", modulo: modulo_catalogos, link_to: "/catalogos/clientes")

# # Módulo Estadísticas
Menu.create!(codigo: "ESTADISTICAS", nombre: "Estadísticas por período", modulo: modulo_estadisticas, link_to: "/estadisticas/estadisticas_periodo")

# # Módulo Finanzas
Menu.create!(codigo: "GASTOS_OPERATIVOS", nombre: "Gastos Operativos", modulo: modulo_finanzas, link_to: "/finanzas/gastos_operativos")
Menu.create!(codigo: "DETALLE_PAGOS_EMPLEADOS", nombre: "Nómina Empleados", modulo: modulo_finanzas, link_to: "/finanzas/detalle_pagos_empleados")

# # Módulo Gestión de Seguridad
Menu.create!(codigo: "MODULOS", nombre: "Módulos", modulo: modulo_seguridad, link_to: "/seguridad/modulos")
Menu.create!(codigo: "MENUS", nombre: "Menús", modulo: modulo_seguridad, link_to: "/seguridad/menus")
Menu.create!(codigo: "USUARIOS", nombre: "Usuarios", modulo: modulo_seguridad, link_to: "/seguridad/usuarios")
Menu.create!(codigo: "EMPLEADOS", nombre: "Empleados", modulo: modulo_seguridad, link_to: "/seguridad/empleados")

menu_padre_gestion_roles = Menu.create!(codigo: "SM001", nombre: "Gestión de Roles", modulo: modulo_seguridad, link_to: "/seguridad/roles")
Menu.create!(codigo: "ROLES", nombre: "Roles", modulo: modulo_seguridad, parent: menu_padre_gestion_roles, link_to: "/seguridad/roles")

# -------------  Roles y Usuarios  ------------- #
# Empleados

empleado_admin = Empleado.create!(primer_nombre: "Administrador", primer_apellido: "Sistema", cargo: "Administrador", salario_base: 1000000, viatico_transporte: 0)
empleado_usuario = Empleado.create!(primer_nombre: "Usuario", primer_apellido: "Sistema", cargo: "Usuario", salario_base: 50000, viatico_transporte: 0)

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

[menu_ventas, menu_inventario, menu_clientes].each do |menu|
  RolesMenu.create!(rol: seller_role, menu: menu)
end

# Roles - Usuarios
RolesUser.create!(user: user_admin, rol: admin_role)
RolesUser.create!(user: user_normal, rol: seller_role)
