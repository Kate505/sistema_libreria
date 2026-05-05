// pago_finalizar_controller.js
// Stimulus controller para el modal de finalización de transacción.
// Maneja: selección de moneda, tasa de cambio, método de pago y cálculo de vuelto.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "tasaContainer",
    "tasa",
    "efectivoContainer",
    "monedaLabel",
    "monedaPrefix",
    "montoRecibido",
    "vueltoPreview",
    "vueltoValor",
    "vueltoInsuficiente",
    "totalUsdContainer",
    "totalUsd",
    "submitBtn"
  ]

  connect() {
    this.moneda = "NIO"
    this.metodo = null
    this.totalNios = parseFloat(
      this.element.querySelector("input[name='total_nios']")?.value || "0"
    )
  }

  // Cambio de moneda (NIO / USD)
  monedaChange(event) {
    this.moneda = event.target.value

    if (this.moneda === "USD") {
      this.tasaContainerTarget.classList.remove("hidden")
      this.totalUsdContainerTarget.classList.remove("hidden")
      this.monedaLabelTarget.textContent = "US$"
      this.monedaPrefixTarget.textContent = "US$"
    } else {
      this.tasaContainerTarget.classList.add("hidden")
      this.totalUsdContainerTarget.classList.add("hidden")
      this.monedaLabelTarget.textContent = "C$"
      this.monedaPrefixTarget.textContent = "C$"
    }

    // Recalcular (incluye equivalente en US$ si aplica)
    this.calcularVuelto()
  }

  // Cambio de método de pago
  metodoPagoChange(event) {
    this.metodo = event.target.value

    if (this.metodo === "E") {
      this.efectivoContainerTarget.classList.remove("hidden")
    } else {
      this.efectivoContainerTarget.classList.add("hidden")
      this.vueltoPreviewTarget.classList.add("hidden")
    }
  }

  // Cálculo de vuelto en tiempo real
  calcularVuelto() {
    const monto    = parseFloat(this.montoRecibidoTarget.value) || 0
    const tasa     = this.hasTasaTarget ? (parseFloat(this.tasaTarget.value) || 0) : 0
    const total    = this.totalNios

    // Actualizar equivalente en dólares
    if (this.moneda === "USD" && tasa > 0 && this.hasTotalUsdContainerTarget) {
      const totalUsd = total / tasa
      this.totalUsdTarget.textContent = `US$ ${totalUsd.toFixed(2)}`
    }

    // El vuelto solo aplica para efectivo
    if (this.metodo !== "E") return

    // Convertir monto recibido a NIO si es USD
    let montoNios = monto
    if (this.moneda === "USD" && tasa > 0) {
      montoNios = monto * tasa
    }

    const vuelto = montoNios - total

    if (monto > 0) {
      this.vueltoPreviewTarget.classList.remove("hidden")

      if (vuelto >= 0) {
        this.vueltoValorTarget.textContent = `C$ ${vuelto.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')}`
        this.vueltoInsuficienteTarget.classList.add("hidden")
        this.vueltoPreviewTarget.classList.remove("border-error/30", "bg-error/10")
        this.submitBtnTarget.disabled = false
        this.submitBtnTarget.classList.remove("btn-disabled")
      } else {
        this.vueltoValorTarget.textContent = `C$ ${vuelto.toFixed(2)}`
        this.vueltoInsuficienteTarget.classList.remove("hidden")
        this.submitBtnTarget.disabled = true
        this.submitBtnTarget.classList.add("btn-disabled")
      }
    } else {
      this.vueltoPreviewTarget.classList.add("hidden")
    }
  }
}
