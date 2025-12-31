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

ActiveRecord::Schema[8.0].define(version: 2025_12_29_203203) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "menus", force: :cascade do |t|
    t.string "codigo", limit: 10, null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "primer_nombre", default: "", null: false
    t.string "primer_apellido", default: "", null: false
    t.string "segundo_nombre"
    t.string "segundo_apellido"
    t.boolean "pasivo", default: false, null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "menus", "menus"
  add_foreign_key "menus", "modulos"
  add_foreign_key "roles_menus", "menus"
  add_foreign_key "roles_menus", "roles", column: "rol_id"
  add_foreign_key "roles_users", "roles", column: "rol_id"
  add_foreign_key "roles_users", "users"
  add_foreign_key "sessions", "users"
end
