require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "no autenticado puede ver login" do
    get new_session_url
    assert_response :success
  end

  test "autenticado es redireccionado a la raiz al intentar ver login" do
    user = users(:one)
    rol = Rol.find_or_create_by!(nombre: "Admin", pasivo: false)
    RolesUser.find_or_create_by!(rol: rol, user: user)

    sign_in user
    get new_session_url
    assert_redirected_to root_url
  end
end
