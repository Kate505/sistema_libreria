# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_01_04_005831) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categorias", force: :cascade do |t|
    t.string "nombre", limit: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clientes", force: :cascade do |t|
    t.string "primer_nombre", limit: 50
    t.string "segundo_nombre", limit: 50
    t.string "primer_apellido", limit: 50
    t.string "segundo_apellido", limit: 50
    t.string "email", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "detalle_ordenes_de_compra", force: :cascade do |t|
    t.bigint "orden_de_compra_id", null: false
    t.bigint "producto_id", null: false
    t.integer "cantidad", null: false
    t.decimal "precio_unitario_compra", precision: 10, scale: 2, null: false
    t.decimal "costo_unitario_compra_calculado", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["orden_de_compra_id"], name: "index_detalle_ordenes_de_compra_on_orden_de_compra_id"
    t.index ["producto_id"], name: "index_detalle_ordenes_de_compra_on_producto_id"
  end

  create_table "detalle_pagos_empleados", force: :cascade do |t|
    t.bigint "gasto_operativo_id", null: false
    t.bigint "empleado_id", null: false
    t.decimal "salario_base", precision: 10, scale: 2
    t.decimal "pago_transporte", precision: 10, scale: 2
    t.decimal "comisiones_ventas", precision: 10, scale: 2
    t.decimal "horas_extra", precision: 10, scale: 2, default: "0.0"
    t.decimal "salario_bruto", precision: 10, scale: 2
    t.decimal "deduccion_inss", precision: 10, scale: 2
    t.decimal "deduccion_impuestos", precision: 10, scale: 2
    t.decimal "otras_deducciones", precision: 10, scale: 2, default: "0.0"
    t.decimal "salario_neto", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["empleado_id"], name: "index_detalle_pagos_empleados_on_empleado_id"
    t.index ["gasto_operativo_id"], name: "index_detalle_pagos_empleados_on_gasto_operativo_id"
  end

  create_table "detalle_venta", force: :cascade do |t|
    t.bigint "venta_id", null: false
    t.bigint "producto_id", null: false
    t.integer "cantidad", null: false
    t.decimal "precio_unitario_venta", precision: 10, scale: 2, null: false
    t.decimal "precio_historico_al_momento_de_venta", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["producto_id"], name: "index_detalle_venta_on_producto_id"
    t.index ["venta_id"], name: "index_detalle_venta_on_venta_id"
  end

  create_table "empleados", force: :cascade do |t|
    t.string "primer_nombre", limit: 50, null: false
    t.string "segundo_nombre", limit: 50
    t.string "primer_apellido", limit: 50, null: false
    t.string "segundo_apellido", limit: 50
    t.string "cargo", limit: 100
    t.decimal "salario_base", precision: 10, scale: 2, null: false
    t.decimal "viatico_transporte", precision: 10, scale: 2, default: "0.0"
    t.date "fecha_contratacion"
    t.boolean "pasivo", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gastos_operativos", force: :cascade do |t|
    t.integer "periodo_mes", null: false
    t.integer "periodo_year", null: false
    t.decimal "costos_alquiler", precision: 10, scale: 2, default: "0.0"
    t.decimal "costo_utilidades", precision: 10, scale: 2, default: "0.0"
    t.decimal "costo_mantenimiento", precision: 10, scale: 2, default: "0.0"
    t.decimal "costo_salario_total", precision: 10, scale: 2, default: "0.0"
    t.decimal "gran_total_gastos", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["periodo_mes", "periodo_year"], name: "index_gastos_operativos_on_periodo_mes_and_periodo_year", unique: true
  end

  create_table "menus", force: :cascade do |t|
    t.string "codigo", limit: 30, null: false
    t.string "nombre", limit: 50, null: false
    t.bigint "modulo_id", null: false
    t.bigint "menu_id"
    t.string "link_to", null: false
    t.boolean "pasivo", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["codigo", "modulo_id", "menu_id"], name: "menus_codigo_modulo_id_menu_id_uq", unique: true
    t.index ["codigo"], name: "index_menus_on_codigo", unique: true
    t.index ["menu_id"], name: "index_menus_on_menu_id"
    t.index ["modulo_id"], name: "index_menus_on_modulo_id"
  end

  create_table "modulos", force: :cascade do |t|
    t.string "nombre", limit: 50, null: false
    t.string "icono", null: false
    t.string "link_to", null: false
    t.boolean "pasivo", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nombre"], name: "index_modulos_on_nombre", unique: true
  end

  create_table "ordenes_de_compra", force: :cascade do |t|
    t.bigint "proveedor_id", null: false
    t.date "fecha_compra", null: false
    t.string "numero_factura", limit: 50
    t.decimal "costo_total_flete", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proveedor_id"], name: "index_ordenes_de_compra_on_proveedor_id"
  end

  create_table "productos", force: :cascade do |t|
    t.bigint "categorias_id", null: false
    t.string "sku", limit: 50
    t.string "nombre", limit: 200, null: false
    t.boolean "descuento", default: false, null: false
    t.integer "descuento_maximo", default: 0
    t.integer "stock_actual", default: 0
    t.integer "stock_minimo_limite", default: 1
    t.integer "stock_maximo_limite", default: 1
    t.decimal "costo_promedio_ponderado", precision: 10, scale: 2, default: "0.0"
    t.decimal "ultimo_precio_compra", precision: 10, scale: 2
    t.decimal "precio_venta", precision: 10, scale: 2, null: false
    t.decimal "precio_venta_al_mayor", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["categorias_id"], name: "index_productos_on_categorias_id"
    t.index ["sku"], name: "index_productos_on_sku", unique: true
  end

  create_table "proveedores", force: :cascade do |t|
    t.string "nombre", limit: 150, null: false
    t.string "telefono", limit: 255
    t.string "direccion", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "nombre", null: false
    t.boolean "pasivo", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles_menus", force: :cascade do |t|
    t.bigint "rol_id", null: false
    t.bigint "menu_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_id"], name: "index_roles_menus_on_menu_id"
    t.index ["rol_id", "menu_id"], name: "roles_menus_rol_id_menu_id_uq", unique: true
    t.index ["rol_id"], name: "index_roles_menus_on_rol_id"
  end

  create_table "roles_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "rol_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rol_id"], name: "index_roles_users_on_rol_id"
    t.index ["user_id", "rol_id"], name: "roles_users_user_id_rol_id_uq", unique: true
    t.index ["user_id"], name: "index_roles_users_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.boolean "pasivo", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "empleado_id", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["empleado_id"], name: "index_users_on_empleado_id", unique: true
  end

  create_table "ventas", force: :cascade do |t|
    t.bigint "cliente_id"
    t.datetime "fecha_venta", default: -> { "CURRENT_TIMESTAMP" }
    t.string "metodo_pago", limit: 2
    t.decimal "cantidad_total", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_ventas_on_cliente_id"
  end

  add_foreign_key "detalle_ordenes_de_compra", "ordenes_de_compra"
  add_foreign_key "detalle_ordenes_de_compra", "productos"
  add_foreign_key "detalle_pagos_empleados", "empleados"
  add_foreign_key "detalle_pagos_empleados", "gastos_operativos"
  add_foreign_key "detalle_venta", "productos"
  add_foreign_key "detalle_venta", "ventas"
  add_foreign_key "menus", "menus"
  add_foreign_key "menus", "modulos"
  add_foreign_key "ordenes_de_compra", "proveedores"
  add_foreign_key "productos", "categorias", column: "categorias_id"
  add_foreign_key "roles_menus", "menus"
  add_foreign_key "roles_menus", "roles", column: "rol_id"
  add_foreign_key "roles_users", "roles", column: "rol_id"
  add_foreign_key "roles_users", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "empleados"
  add_foreign_key "ventas", "clientes"
end
