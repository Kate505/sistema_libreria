require "test_helper"

class Inventario::ProductosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in(@user)

    ensure_menu_access_for!(@user, "PRODUCTOS")
  end

  test "create producto creates brand when nombre_marca does not exist" do
    categoria = Categoria.first || Categoria.create!(nombre: "Categoría Test")

    assert_difference("Producto.count", 1) do
      assert_difference("Marca.count", 1) do
        post inventario_productos_path, params: {
          producto: {
            sku: "TST-001",
            nombre: "Producto Test",
            categoria_id: categoria.id,
            nombre_marca: "Marca Inexistente",
            precio_venta: 10,
            precio_venta_al_mayor: 9,
            stock_actual: 0,
            stock_minimo_limite: 1,
            stock_maximo_limite: 1
          }
        }
      end
    end

    producto = Producto.order(:id).last
    assert_equal "Marca Inexistente", producto.marca.nombre
  end

  test "create producto reuses existing brand when nombre_marca exists" do
    categoria = Categoria.first || Categoria.create!(nombre: "Categoría Test")
    marca = Marca.create!(nombre: "Marca Existente")

    assert_difference("Producto.count", 1) do
      assert_no_difference("Marca.count") do
        post inventario_productos_path, params: {
          producto: {
            sku: "TST-002",
            nombre: "Producto Test 2",
            categoria_id: categoria.id,
            nombre_marca: "Marca Existente",
            precio_venta: 12,
            precio_venta_al_mayor: 11,
            stock_actual: 0,
            stock_minimo_limite: 1,
            stock_maximo_limite: 1
          }
        }
      end
    end

    producto = Producto.order(:id).last
    assert_equal marca.id, producto.marca_id
  end

  test "consulta precios paginates results and preserves the search term in links" do
    ensure_menu_access_for!(@user, "CONSULTA_PRECIOS")
    create_productos_for_consulta_precios!(11)

    get consulta_precios_inventario_productos_path, params: { q: "Producto" }

    assert_response :success
    assert_includes response.body, "Producto 01"
    assert_includes response.body, "Producto 10"
    refute_includes response.body, "Producto 11"
    assert_includes response.body, "q=Producto"
    assert_includes response.body, "page=2"

    get consulta_precios_inventario_productos_path, params: { q: "Producto", page: 2 }

    assert_response :success
    assert_includes response.body, "Producto 11"
    refute_includes response.body, "Producto 01"
  end

  test "access to consulta_precios is allowed with CONSULTA_PRECIOS but denied with only PRODUCTOS" do
    # At setup, user has PRODUCTOS. Verify they can access index but NOT consulta_precios
    get inventario_productos_path
    assert_response :success

    get consulta_precios_inventario_productos_path
    assert_redirected_to root_path
    assert_equal "No tienes permisos para acceder a este recurso.", flash[:alert]

    # Strip their roles/menus access and give them ONLY CONSULTA_PRECIOS
    RolesMenu.delete_all
    ensure_menu_access_for!(@user, "CONSULTA_PRECIOS")

    # Verify they can access consulta_precios but NOT index
    get consulta_precios_inventario_productos_path
    assert_response :success

    get inventario_productos_path
    assert_redirected_to root_path
    assert_equal "No tienes permisos para acceder a este recurso.", flash[:alert]
  end

  private

  def ensure_menu_access_for!(user, menu_code)
    # Estructura mínima para que `user.can_access_menu?` sea true.
    modulo = Modulo.find_or_create_by!(nombre: "Inventario") do |m|
      m.icono = "inventario.svg"
      m.link_to = "/inventario/productos"
      m.pasivo = false if m.respond_to?(:pasivo=)
    end

    menu = Menu.find_or_create_by!(codigo: menu_code) do |mn|
      mn.nombre = "Productos"
      mn.modulo = modulo
      mn.link_to = "/inventario/productos"
      mn.pasivo = false if mn.respond_to?(:pasivo=)
    end

    rol = Rol.find_or_create_by!(nombre: "Admin")

    RolesMenu.find_or_create_by!(rol_id: rol.id, menu_id: menu.id)
    RolesUser.find_or_create_by!(rol_id: rol.id, user_id: user.id)
  end

  def create_productos_for_consulta_precios!(total)
    categoria = Categoria.create!(nombre: "Categoría Consulta Precios #{rand(100_000)}")
    sku_prefix = "TST-#{rand(100_000)}"

    total.times do |index|
      Producto.create!(
        sku: "#{sku_prefix}-#{index + 1}",
        nombre: format("Producto %02d", index + 1),
        categoria: categoria,
        descuento: false,
        precio_venta: 10 + index,
        precio_venta_al_mayor: 9 + index,
        stock_actual: index,
        stock_minimo_limite: 1,
        stock_maximo_limite: 5
      )
    end
  end
end
