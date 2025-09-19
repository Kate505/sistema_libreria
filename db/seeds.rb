# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Limpieza de datos previos
Session.delete_all
RolesUser.delete_all
RolesMenu.delete_all
Menu.delete_all
Modulo.delete_all
Rol.delete_all
User.delete_all

admin_user = User.create!(email_address: "admin@gmail.com", password: "123456", password_confirmation: "123456")
normal_user = User.create!(email_address: "user@gmail.com", password: "123456", password_confirmation: "123456")

facturacion = Modulo.create!(nombre: "Facturación", icono: "facturacion.png", link_to: "/facturacion")
inventario = Modulo.create!(nombre: "Inventario", icono: "inventario.png", link_to: "/inventario")
catalogos = Modulo.create!(nombre: "Catálogos", icono: "catalogos.png", link_to: "/catalogos")
estadisticas = Modulo.create!(nombre: "Estadísticas", icono: "estadisticas.png", link_to: "/estadisticas")
seguridad = Modulo.create!(nombre: "Gestión de Seguridad", icono: "seguridad.png", link_to: "/seguridad")

facturacion_menu = Menu.create!(codigo: "MI001", nombre: "Inicio", icono: "facturacion.png", modulo: facturacion, link_to: "/facturacion/inicio")
inventario_menu = Menu.create!(codigo: "MI002", nombre: "Inicio", icono: "inventario.png", modulo: inventario, link_to: "/inventario/inicio")
catalogos_menu = Menu.create!(codigo: "MI003", nombre: "Inicio", icono: "catalogos.png", modulo: catalogos, link_to: "/catalogos/inicio")
estadisticas_menu = Menu.create!(codigo: "MI004", nombre: "Inicio", icono: "estadisticas.png", modulo: estadisticas, link_to: "/estadisticas/inicio")
seguridad_menu = Menu.create!(codigo: "MI005", nombre: "Inicio", icono: "seguridad.png", modulo: seguridad, link_to: "/seguridad/inicio")

seguridad_menu1 = Menu.create!(codigo: "MGS001", nombre: "Módulos", icono: "seguridad.png", modulo: seguridad, link_to: "/seguridad/modulos/index")
seguridad_menu2 = Menu.create!(codigo: "MGS002", nombre: "Menús", icono: "seguridad.png", modulo: seguridad, link_to: "/seguridad/menus/index")
seguridad_menu3 = Menu.create!(codigo: "MGS003", nombre: "Usuarios", icono: "seguridad.png", modulo: seguridad, link_to: "/seguridad/usuarios/index")
seguridad_menu4 = Menu.create!(codigo: "MGS004", nombre: "Gestión de Roles", icono: "seguridad.png", modulo: seguridad, link_to: "/seguridad/roles")
seguridad_menu5 = Menu.create!(codigo: "MGS005", nombre: "Roles", icono: "seguridad.png", modulo: seguridad, parent: seguridad_menu4, link_to: "/seguridad/roles/index")
seguridad_menu6 = Menu.create!(codigo: "MGS006", nombre: "Roles - Menús", icono: "seguridad.png", modulo: seguridad, parent: seguridad_menu4, link_to: "/seguridad/roles_menus/index")
seguridad_menu7 = Menu.create!(codigo: "MGS007", nombre: "Roles por Usuario", icono: "seguridad.png", modulo: seguridad, parent: seguridad_menu4, link_to: "/seguridad/roles_usuarios/index")

admin_role = Rol.create!(nombre: "Administrador")
seller_role = Rol.create!(nombre: "Vendedor")

Menu.all.each do |menu|
  RolesMenu.create!(rol: admin_role, menu: menu)
end

[facturacion_menu, inventario_menu].each do |menu|
  RolesMenu.create!(rol: seller_role, menu: menu)
end

RolesUser.create!(user: admin_user, rol: admin_role)
RolesUser.create!(user: normal_user, rol: seller_role)
