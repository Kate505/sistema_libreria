require "test_helper"

class GastoOperativoTest < ActiveSupport::TestCase
  test "periodo_legible formatting" do
    gasto = GastoOperativo.new(fecha: Date.new(2026, 5, 15), cantidad: 100, descripcion: "Prueba")
    gasto.save!
    assert_equal "Mayo 2026", gasto.periodo_legible
  end
end
