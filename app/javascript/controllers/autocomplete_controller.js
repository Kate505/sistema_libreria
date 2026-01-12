import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
	static targets = ["input", "hidden", "results", "loading"]
	static values = { url: String }

	connect() {
		this.resultsTarget.classList.add("hidden")
		// Ocultar icono de carga si existe
		if (this.loadingTarget) this.loadingTarget.classList.add("hidden")
	}

	search() {
		// 1. DEBOUNCE: Cancelar el temporizador anterior si el usuario sigue tecleando
		clearTimeout(this.timeout)

		// 2. Establecer un nuevo temporizador (300ms es el estándar de la industria)
		this.timeout = setTimeout(() => {
			this.performSearch()
		}, 300)
	}

	performSearch() {
		const query = this.inputTarget.value.trim()

		// No buscar si es muy corto
		if (query.length < 2) {
			this.resultsTarget.classList.add("hidden")
			return
		}

		// 3. ABORT CONTROLLER: Cancelar petición HTTP anterior si aún está viajando
		if (this.abortController) {
			this.abortController.abort()
		}
		this.abortController = new AbortController()

		// Mostrar estado de "Cargando..."
		if (this.loadingTarget) this.loadingTarget.classList.remove("hidden")

		fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, {
			signal: this.abortController.signal // Vinculamos la señal de aborto
		})
			.then(response => {
				if (!response.ok) throw new Error("Network response was not ok")
				return response.json()
			})
			.then(data => {
				this.renderResults(data)
			})
			.catch(error => {
				// Ignoramos errores de aborto (es normal cuando el usuario escribe rápido)
				if (error.name !== 'AbortError') {
					console.error("Error en búsqueda:", error)
				}
			})
			.finally(() => {
				// Ocultar "Cargando..." solo si no fue abortado (para evitar parpadeos)
				if (this.loadingTarget && !this.abortController.signal.aborted) {
					this.loadingTarget.classList.add("hidden")
				}
			})
	}

	renderResults(data) {
		this.resultsTarget.innerHTML = ""

		if (data.length > 0) {
			data.forEach(item => {
				const li = document.createElement("li")
				const a = document.createElement("a")
				// Renderizado seguro
				a.textContent = item.text
				// Evento para seleccionar
				a.addEventListener("click", (e) => {
					e.preventDefault()
					this.select(item)
				})

				li.appendChild(a)
				this.resultsTarget.appendChild(li)
			})
			this.resultsTarget.classList.remove("hidden")
		} else {
			// Opcional: Mostrar mensaje de "No encontrado"
			const li = document.createElement("li")
			li.innerHTML = `<span class="text-gray-500 italic cursor-default pointer-events-none">No se encontraron resultados</span>`
			this.resultsTarget.appendChild(li)
			this.resultsTarget.classList.remove("hidden")
		}
	}

	select(item) {
		this.inputTarget.value = item.text
		this.hiddenTarget.value = item.id
		this.resultsTarget.classList.add("hidden")
		// Disparar evento de cambio por si otros controladores dependen de este input
		this.hiddenTarget.dispatchEvent(new Event('change'))
	}

	hide(event) {
		if (!this.element.contains(event.target)) {
			this.resultsTarget.classList.add("hidden")
		}
	}
}