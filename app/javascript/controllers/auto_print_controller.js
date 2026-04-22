import { Controller } from "@hotwired/stimulus"

// Abre el PDF de la factura en una nueva pestaña y lanza el diálogo de impresión.
// Nota: el navegador puede bloquear popups si no se dispara desde una acción del usuario.
export default class extends Controller {
  static values = {
    url: String
  }

  connect() {
    if (!this.hasUrlValue || !this.urlValue) return

    // Intentar abrir en nueva pestaña/ventana
    const w = window.open(this.urlValue, "_blank")
    if (!w) return

    const tryPrint = () => {
      try {
        w.focus()
        w.print()
      } catch (_e) {
        // Ignorar errores del visor PDF del navegador
      }
    }

    // Algunos visores disparan load, otros tardan más.
    w.addEventListener("load", tryPrint)
    setTimeout(tryPrint, 1200)
  }
}

