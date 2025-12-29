import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
	static targets = ["toggle"]

	// Esta acción se ejecuta al hacer clic en el botón de la versión compacta
	expandAndOpen(event) {
		// 1. Abrir el sidebar marcando el checkbox del drawer
		if (this.hasToggleTarget) {
			this.toggleTarget.checked = true
		}

		// 2. Obtener el ID del elemento details objetivo
		// Este ID lo pasaremos mediante data-target-id en el helper
		const targetId = event.currentTarget.dataset.targetId
		const detailsElement = document.getElementById(targetId)

		// 3. Abrir el elemento details
		if (detailsElement) {
			detailsElement.open = true

			// Opcional: hacer scroll hacia el elemento si la lista es muy larga
			// detailsElement.scrollIntoView({ behavior: "smooth", block: "center" })
		}
	}
}
