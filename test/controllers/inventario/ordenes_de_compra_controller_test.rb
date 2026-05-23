require "test_helper"

class Inventario::OrdenesDeCompraControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in(@user)

    ensure_menu_access_for!(@user, "ORDENES_DE_COMPRA")
  end

  test "index renders successfully" do
    get inventario_ordenes_de_compra_path
    assert_response :success
  end

  test "create supply order associates with current user" do
    proveedor = Proveedor.first || Proveedor.create!(nombre: "Proveedor Test", telefono: "12345678", direccion: "Direccion")

    assert_difference("OrdenDeCompra.count", 1) do
      post inventario_ordenes_de_compra_path, params: {
        orden_de_compra: {
          proveedor_id: proveedor.id,
          fecha_compra: Date.current,
          numero_factura: "FACT-1234",
          costo_total_flete: 50.00
        }
      }
    end

    orden = OrdenDeCompra.last
    assert_equal @user.id, orden.user_id
    assert_equal "FACT-1234", orden.numero_factura
  end

  private

  def ensure_menu_access_for!(user, menu_code)
    modulo = Modulo.find_or_create_by!(nombre: "Inventario") do |m|
      m.icono = "inventario.svg"
      m.link_to = "/inventario"
      m.pasivo = false if m.respond_to?(:pasivo=)
    end

    menu = Menu.find_or_create_by!(codigo: menu_code) do |mn|
      mn.nombre = "Órdenes de Abastecimiento"
      mn.modulo = modulo
      mn.link_to = "/inventario/ordenes_de_compra"
      mn.pasivo = false if mn.respond_to?(:pasivo=)
    end

    rol = Rol.find_or_create_by!(nombre: "Admin")

    RolesMenu.find_or_create_by!(rol_id: rol.id, menu_id: menu.id)
    RolesUser.find_or_create_by!(rol_id: rol.id, user_id: user.id)
  end
end
