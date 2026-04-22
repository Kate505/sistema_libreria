require "test_helper"

class Facturacion::VentasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in(@user)

    ensure_menu_access_for!(@user, "VENTAS")
  end

  test "historial aplica por defecto finalizadas del dia actual" do
    hoy = Time.current

    venta_hoy_finalizada = Venta.create!(
      fecha_venta: hoy.beginning_of_day + 10.hours,
      finalizada: true,
      cantidad_total: 10
    )
    venta_hoy_pendiente = Venta.create!(
      fecha_venta: hoy.beginning_of_day + 11.hours,
      finalizada: false,
      cantidad_total: 20
    )
    venta_ayer_finalizada = Venta.create!(
      fecha_venta: (hoy - 1.day).beginning_of_day + 10.hours,
      finalizada: true,
      cantidad_total: 30
    )

    get historial_facturacion_ventas_path

    assert_redirected_to historial_facturacion_ventas_path(
      fecha_desde: Date.current.iso8601,
      fecha_hasta: Date.current.iso8601,
      estado: "finalizada"
    )

    follow_redirect!
    assert_response :success

    assert_includes response.body, "##{venta_hoy_finalizada.id}"
    assert_not_includes response.body, "##{venta_hoy_pendiente.id}"
    assert_not_includes response.body, "##{venta_ayer_finalizada.id}"
  end

  test "show devuelve modal cuando se solicita desde el turbo-frame venta_detalle_modal" do
    categoria = Categoria.first || Categoria.create!(nombre: "Categoría Test")
    producto = Producto.create!(
      categoria_id: categoria.id,
      sku: "MOD-001",
      nombre: "Producto Modal",
      precio_venta: 25,
      precio_venta_al_mayor: 20,
      stock_actual: 50,
      stock_minimo_limite: 1,
      stock_maximo_limite: 100
    )

    venta = Venta.create!(
      fecha_venta: Time.current,
      finalizada: true,
      cantidad_total: 0
    )

    DetalleVenta.create!(
      venta: venta,
      producto: producto,
      cantidad: 2,
      precio_unitario_venta: 25
    )

    get facturacion_venta_path(venta), headers: { "Turbo-Frame" => "venta_detalle_modal" }
    assert_response :success

    assert_includes response.body, "<turbo-frame id=\"venta_detalle_modal\""
    assert_includes response.body, "venta_detalle_modal_dialog"
    assert_includes response.body, "Producto Modal"
  end

  private

  def ensure_menu_access_for!(user, menu_code)
    modulo = Modulo.find_or_create_by!(nombre: "Facturación") do |m|
      m.icono = "receipt"
      m.link_to = "/facturacion/ventas"
      m.pasivo = false if m.respond_to?(:pasivo=)
    end

    menu = Menu.find_or_create_by!(codigo: menu_code) do |mn|
      mn.nombre = "Ventas"
      mn.modulo = modulo
      mn.link_to = "/facturacion/ventas"
      mn.pasivo = false if mn.respond_to?(:pasivo=)
    end

    rol = Rol.find_or_create_by!(nombre: "Admin")

    RolesMenu.find_or_create_by!(rol_id: rol.id, menu_id: menu.id)
    RolesUser.find_or_create_by!(rol_id: rol.id, user_id: user.id)
  end
end

