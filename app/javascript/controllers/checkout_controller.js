import { Controller } from "@hotwired/stimulus"

// Manages the checkout modal: payment method selection, currency toggle,
// cash amount input, and change calculation.
export default class extends Controller {
  static targets = [
    "modal",
    "metodoPago",
    "metodoPagoHidden",
    "efectivoFields",
    "moneda",
    "montoRecibido",
    "vueltoDisplay",
    "vueltoAmount",
    "totalCordobas",
    "totalConvertido",
    "monedaLabel",
    "submitBtn",
    "errorMsg"
  ]

  static values = {
    total: Number,
    tasaCambio: { type: Number, default: 36.6243 }
  }

  connect() {
    this.metodoSeleccionado = null
  }

  open() {
    this.modalTarget.showModal()
    this.reset()
  }

  close() {
    this.modalTarget.close()
    this.reset()
  }

  reset() {
    this.metodoSeleccionado = null
    this.metodoPagoTargets.forEach(el => el.classList.remove("btn-active", "btn-primary"))
    this.metodoPagoHiddenTarget.value = ""
    this.efectivoFieldsTarget.classList.add("hidden")
    this.vueltoDisplayTarget.classList.add("hidden")
    this.montoRecibidoTarget.value = ""
    this.submitBtnTarget.disabled = true
    this.hideError()

    // Reset moneda to córdobas
    this.monedaTargets.forEach(el => {
      el.classList.remove("btn-active", "btn-primary")
      if (el.dataset.moneda === "NIO") {
        el.classList.add("btn-active", "btn-primary")
      }
    })
    this.monedaActual = "NIO"
    this.updateTotalConvertido()
  }

  selectMetodo(event) {
    const metodo = event.currentTarget.dataset.metodo

    this.metodoPagoTargets.forEach(el => {
      el.classList.remove("btn-active", "btn-primary")
    })
    event.currentTarget.classList.add("btn-active", "btn-primary")

    this.metodoSeleccionado = metodo
    this.metodoPagoHiddenTarget.value = metodo

    // Show/hide cash-specific fields
    if (metodo === "E") {
      this.efectivoFieldsTarget.classList.remove("hidden")
      this.submitBtnTarget.disabled = true
      this.montoRecibidoTarget.focus()
    } else {
      this.efectivoFieldsTarget.classList.add("hidden")
      this.vueltoDisplayTarget.classList.add("hidden")
      this.submitBtnTarget.disabled = false
    }

    this.hideError()
  }

  selectMoneda(event) {
    const moneda = event.currentTarget.dataset.moneda
    this.monedaActual = moneda

    this.monedaTargets.forEach(el => {
      el.classList.remove("btn-active", "btn-primary")
    })
    event.currentTarget.classList.add("btn-active", "btn-primary")

    this.updateTotalConvertido()
    this.calcularVuelto()
  }

  updateTotalConvertido() {
    if (this.monedaActual === "USD") {
      const totalUSD = (this.totalValue / this.tasaCambioValue).toFixed(2)
      this.totalConvertidoTarget.textContent = `Equivalente: US$ ${totalUSD}`
      this.totalConvertidoTarget.classList.remove("hidden")
      this.monedaLabelTarget.textContent = "US$"
    } else {
      this.totalConvertidoTarget.classList.add("hidden")
      this.monedaLabelTarget.textContent = "C$"
    }
  }

  calcularVuelto() {
    const montoInput = parseFloat(this.montoRecibidoTarget.value)

    if (isNaN(montoInput) || montoInput <= 0) {
      this.vueltoDisplayTarget.classList.add("hidden")
      this.submitBtnTarget.disabled = true
      return
    }

    let montoEnCordobas
    if (this.monedaActual === "USD") {
      montoEnCordobas = montoInput * this.tasaCambioValue
    } else {
      montoEnCordobas = montoInput
    }

    const vuelto = montoEnCordobas - this.totalValue

    this.vueltoDisplayTarget.classList.remove("hidden")

    if (vuelto < 0) {
      this.vueltoAmountTarget.textContent = `Faltan C$ ${Math.abs(vuelto).toFixed(2)}`
      this.vueltoAmountTarget.className = "font-bold text-xl tabular-nums text-error"
      this.submitBtnTarget.disabled = true
    } else {
      this.vueltoAmountTarget.textContent = `C$ ${vuelto.toFixed(2)}`
      this.vueltoAmountTarget.className = "font-bold text-xl tabular-nums text-success"
      this.submitBtnTarget.disabled = false
    }
  }

  submitPago(event) {
    if (!this.metodoSeleccionado) {
      event.preventDefault()
      this.showError("Seleccione un método de pago.")
      return
    }

    if (this.metodoSeleccionado === "E") {
      const monto = parseFloat(this.montoRecibidoTarget.value)
      let montoEnCordobas = this.monedaActual === "USD" ? monto * this.tasaCambioValue : monto

      if (isNaN(monto) || montoEnCordobas < this.totalValue) {
        event.preventDefault()
        this.showError("El monto recibido es insuficiente.")
        return
      }
    }

    this.hideError()
    // The form will submit normally via Turbo
  }

  showError(msg) {
    if (this.hasErrorMsgTarget) {
      this.errorMsgTarget.textContent = msg
      this.errorMsgTarget.classList.remove("hidden")
    }
  }

  hideError() {
    if (this.hasErrorMsgTarget) {
      this.errorMsgTarget.classList.add("hidden")
    }
  }
}
