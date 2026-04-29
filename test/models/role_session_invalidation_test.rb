require "test_helper"

class RoleSessionInvalidationTest < ActiveSupport::TestCase
  test "al desactivar un rol, se cierran sesiones de usuarios que queden sin roles activos" do
    user = users(:two)

    rol = Rol.create!(nombre: "Administrador", pasivo: false)
    RolesUser.create!(user: user, rol: rol)
    session_record = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Rails Testing")

    assert user.has_active_roles?
    assert Session.exists?(session_record.id)

    assert_difference("Session.count", -1) do
      rol.update!(pasivo: true)
    end

    assert_not Session.exists?(session_record.id)
  end

  test "al quitar un rol activo, se cierran sesiones si ya no quedan roles activos" do
    user = users(:two)

    rol = Rol.create!(nombre: "Vendedor", pasivo: false)
    ru = RolesUser.create!(user: user, rol: rol)
    session_record = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Rails Testing")

    assert user.has_active_roles?
    assert Session.exists?(session_record.id)

    assert_difference("Session.count", -1) do
      ru.destroy!
    end

    assert_not user.reload.has_active_roles?
    assert_not Session.exists?(session_record.id)
  end
end

