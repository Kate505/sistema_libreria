require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user fixture is valid" do
    user = users(:one)
    assert user.valid?, "users(:one) debería ser válido"
  end

  test "user belongs to empleado" do
    user = users(:one)
    assert_not_nil user.empleado, "El usuario debería tener un empleado asociado"
  end

  test "email address is normalized to lowercase" do
    user = users(:one)
    assert_equal user.email_address, user.email_address.downcase
  end
end
