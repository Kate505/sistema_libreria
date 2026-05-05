require "test_helper"

class SessionsRolesGuardTest < ActionDispatch::IntegrationTest
  test "no permite iniciar sesión si el usuario no tiene roles asignados" do
    user = users(:two)

    assert_not user.has_active_roles?

    assert_no_difference("Session.count") do
      post session_path, params: { email_address: user.email_address, password: "password" }
    end

    assert_redirected_to new_session_path
    assert_equal "Tu usuario no tiene roles activos asignados. Contacta al administrador.", flash[:alert]
  end

  test "no permite iniciar sesión si todos los roles asignados están pasivos" do
    user = users(:two)

    rol_pasivo = Rol.create!(nombre: "Administrador", pasivo: true)
    RolesUser.create!(user: user, rol: rol_pasivo)

    assert_not user.reload.has_active_roles?

    assert_no_difference("Session.count") do
      post session_path, params: { email_address: user.email_address, password: "password" }
    end

    assert_redirected_to new_session_path
    assert_equal "Tu usuario no tiene roles activos asignados. Contacta al administrador.", flash[:alert]
  end

  test "permite iniciar sesión cuando el usuario tiene al menos un rol activo" do
    user = users(:two)

    rol_activo = Rol.create!(nombre: "Administrador", pasivo: false)
    RolesUser.create!(user: user, rol: rol_activo)

    assert user.reload.has_active_roles?

    assert_difference("Session.count", 1) do
      post session_path, params: { email_address: user.email_address, password: "password" }
    end

    assert_redirected_to root_url
  end

  test "cierra una sesión existente si el usuario queda sin roles activos" do
    user = users(:two)

    # Sin roles activos
    assert_not user.reload.has_active_roles?

    session_record = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Rails Testing")

    jar = ActionDispatch::Request.new(Rails.application.env_config).cookie_jar
    jar.signed[:session_id] = { value: session_record.id, httponly: true }
    cookies[:session_id] = jar[:session_id]

    assert_difference("Session.count", -1) do
      get root_path
    end

    assert_redirected_to new_session_path
    assert_equal "Tu usuario no tiene roles activos asignados. Contacta al administrador.", flash[:alert]
  end
end

