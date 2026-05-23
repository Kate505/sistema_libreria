require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    user = users(:one)
    rol = Rol.find_or_create_by!(nombre: "Admin", pasivo: false)
    RolesUser.find_or_create_by!(rol: rol, user: user)

    sign_in user
    get home_index_url
    assert_response :success
  end
end
