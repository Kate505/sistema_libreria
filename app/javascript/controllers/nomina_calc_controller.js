import { Controller } from "@hotwired/stimulus"

/**
 * Controlador Stimulus: nomina-calc
 *
 * - Al seleccionar un empleado, pre-rellena salario_base, transporte e INSS (7%)
 * - Ante cualquier cambio recalcula salario_bruto y salario_neto en tiempo real
 */
export default class extends Controller {
  static targets = [
    "empleadoSelect",
    "salarioBase",
    "pagoTransporte",
    "comisionesVentas",
    "horasExtra",
    "salarioBruto",
    "deduccionInss",
    "deduccionImpuestos",
    "otrasDeducciones",
    "salarioNeto"
  ]

  connect() {
    this.calcular()
  }

  // Carga datos del empleado desde los data-attributes del option seleccionado
  cargarEmpleado() {
    const select         = this.empleadoSelectTarget
    const selectedOption = select.options[select.selectedIndex]

    if (!selectedOption || !selectedOption.value) return

    const salario    = parseFloat(selectedOption.dataset.salario    || 0)
    const transporte = parseFloat(selectedOption.dataset.transporte || 0)
    const inss       = parseFloat((salario * 0.07).toFixed(2))

    this.salarioBaseTarget.value          = salario.toFixed(2)
    this.pagoTransporteTarget.value       = transporte.toFixed(2)
    this.deduccionInssTarget.value        = inss.toFixed(2)
    this.comisionesVentasTarget.value     = "0.00"
    this.horasExtraTarget.value           = "0.00"
    this.deduccionImpuestosTarget.value   = "0.00"
    this.otrasDedeccionesTarget.value     = "0.00"

    this.calcular()
  }

  // Recalcula salario bruto y neto
  calcular() {
    const salarioBase = this._float(this.salarioBaseTarget)
    const transporte  = this._float(this.pagoTransporteTarget)
    const comisiones  = this._float(this.comisionesVentasTarget)
    const horasExtra  = this._float(this.horasExtraTarget)

    const inss        = this._float(this.deduccionInssTarget)
    const impuestos   = this._float(this.deduccionImpuestosTarget)
    const otras       = this.hasOtrasDedeccionesTarget ? this._float(this.otrasDedeccionesTarget) : 0

    const bruto = salarioBase + transporte + comisiones + horasExtra
    const neto  = Math.max(bruto - inss - impuestos - otras, 0)

    this.salarioBrutoTarget.textContent = "C$ " + this._fmt(bruto)
    this.salarioNetoTarget.textContent  = "C$ " + this._fmt(neto)
  }

  // ----- helpers privados -----

  _float(target) {
    return parseFloat(target.value) || 0
  }

  _fmt(value) {
    return value.toLocaleString("es-NI", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    })
  }
}
