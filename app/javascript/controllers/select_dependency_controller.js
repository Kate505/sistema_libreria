import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {
	static values = {
		url: String,  // La URL a donde pedir los datos (/seguridad/menus/por_modulo)
		param: String // El nombre del parámetro (modulo_id)
	}

	change(event) {
		const value = event.target.value
		const url = `${this.urlValue}?${this.paramValue}=${value}`

		// Usamos Turbo para reemplazar el frame remotamente
		const frame = document.getElementById("menu_padre_select")
		frame.src = url
	}
}
