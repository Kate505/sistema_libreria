require "test_helper"

class Finanzas::GastosOperativosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in(@user)

    ensure_menu_access_for!(@user, "GASTOS_OPERATIVOS")
  end

  test "index renders successfully" do
    get finanzas_gastos_operativos_path
    assert_response :success
  end

  test "create gasto operativo associates with current user" do
    assert_difference("GastoOperativo.count", 1) do
      post finanzas_gastos_operativos_path, params: {
        gasto_operativo: {
          fecha: Date.current,
          cantidad: 150.00,
          descripcion: "Gasto de prueba"
        }
      }
    end

    gasto = GastoOperativo.last
    assert_equal @user.id, gasto.user_id
    assert_equal 150.00, gasto.cantidad
  end

  test "gasto operativo cannot be updated" do
    gasto = GastoOperativo.create!(
      fecha: Date.current,
      cantidad: 100.00,
      descripcion: "Original"
    )

    gasto.descripcion = "Modificado"
    assert_no_changes -> { gasto.reload.descripcion } do
      gasto.save rescue nil
    end
  end

  test "user without ELIMINAR_GASTOS permission cannot delete opex" do
    gasto = GastoOperativo.create!(
      fecha: Date.current,
      cantidad: 100.00,
      descripcion: "Gasto a eliminar"
    )

    assert_no_difference("GastoOperativo.count") do
      delete finanzas_gasto_operativo_path(gasto)
    end

    assert_redirected_to root_path
    assert_equal "No tienes permisos para acceder a este recurso.", flash[:alert]
  end

  test "user with ELIMINAR_GASTOS permission can delete opex" do
    ensure_menu_access_for!(@user, "ELIMINAR_GASTOS")

    gasto = GastoOperativo.create!(
      fecha: Date.current,
      cantidad: 100.00,
      descripcion: "Gasto a eliminar"
    )

    assert_difference("GastoOperativo.count", -1) do
      delete finanzas_gasto_operativo_path(gasto)
    end
  end

  private

  def ensure_menu_access_for!(user, menu_code)
    modulo = Modulo.find_or_create_by!(nombre: "Finanzas") do |m|
      m.icono = "finanzas.svg"
      m.link_to = "/finanzas"
      m.pasivo = false if m.respond_to?(:pasivo=)
    end

    menu = Menu.find_or_create_by!(codigo: menu_code) do |mn|
      mn.nombre = (menu_code == "ELIMINAR_GASTOS" ? "Eliminar Gastos" : "Gastos Operativos")
      mn.modulo = modulo
      mn.link_to = (menu_code == "ELIMINAR_GASTOS" ? "" : "/finanzas/gastos_operativos")
      mn.pasivo = false if mn.respond_to?(:pasivo=)
    end

    rol = Rol.find_or_create_by!(nombre: "Admin")

    RolesMenu.find_or_create_by!(rol_id: rol.id, menu_id: menu.id)
    RolesUser.find_or_create_by!(rol_id: rol.id, user_id: user.id)
  end
end
