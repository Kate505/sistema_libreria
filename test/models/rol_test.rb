require "test_helper"

class RolTest < ActiveSupport::TestCase
  test "destroying a role deletes its associations" do
    rol = Rol.create!(nombre: "Rol Temporal")
    modulo = Modulo.first || Modulo.create!(nombre: "Modulo Temp", icono: "icono.svg", link_to: "")
    menu = Menu.first || Menu.create!(codigo: "TEMP", nombre: "Temp", modulo: modulo, link_to: "")
    user = User.first

    RolesMenu.create!(rol: rol, menu: menu)
    RolesUser.create!(rol: rol, user: user)

    assert_difference("RolesMenu.count", -1) do
      assert_difference("RolesUser.count", -1) do
        rol.destroy!
      end
    end
  end
end
