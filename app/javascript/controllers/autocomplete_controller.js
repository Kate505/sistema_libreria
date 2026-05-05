import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
	static targets = ["input", "hidden", "results", "loading"]
	static values = {
		url: String,
		createUrl: String
	}

	connect() {
		this.resultsTarget.classList.add("hidden")
		// Ocultar icono de carga si existe
		if (this.hasLoadingTarget) this.loadingTarget.classList.add("hidden")
	}

	search() {
		// Si el usuario está escribiendo, el valor id seleccionado ya no es confiable.
		if (this.hasHiddenTarget) this.hiddenTarget.value = ""

		clearTimeout(this.timeout)
		this.timeout = setTimeout(() => {
			this.performSearch()
		}, 300)
	}

	performSearch() {
		const query = this.inputTarget.value.trim()

		if (query.length < 2) {
			this.resultsTarget.classList.add("hidden")
			return
		}

		if (this.abortController) {
			this.abortController.abort()
		}
		this.abortController = new AbortController()

		if (this.hasLoadingTarget) this.loadingTarget.classList.remove("hidden")

		fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, {
			signal: this.abortController.signal
		})
			.then(response => {
				if (!response.ok) throw new Error("Network response was not ok")
				return response.json()
			})
			.then(data => {
				this.renderResults(data, query)
			})
			.catch(error => {
				if (error.name !== 'AbortError') {
					console.error("Error en búsqueda:", error)
				}
			})
			.finally(() => {
				if (this.hasLoadingTarget && !this.abortController.signal.aborted) {
					this.loadingTarget.classList.add("hidden")
				}
			})
	}

	renderResults(data, query) {
		this.resultsTarget.innerHTML = ""

		if (data.length > 0) {
			data.forEach(item => {
				const li = document.createElement("li")
				const a = document.createElement("a")
				a.textContent = item.text
				a.addEventListener("click", (e) => {
					e.preventDefault()
					this.select(item)
				})

				li.appendChild(a)
				this.resultsTarget.appendChild(li)
			})

			this.resultsTarget.classList.remove("hidden")
			return
		}

		// Sin resultados: ofrecer "Crear 'X'" si hay texto
		const q = (query || "").trim()
		if (q.length > 0) {
			const liCreate = document.createElement("li")
			const aCreate = document.createElement("a")
			aCreate.innerHTML = `Crear <strong>“${this.escapeHtml(q)}”</strong>`
			aCreate.addEventListener("click", (e) => {
				e.preventDefault()
				if (this.hasCreateUrlValue && this.createUrlValue) {
					this.createRecord(q)
				} else {
					this.selectTextOnly(q)
				}
			})
			liCreate.appendChild(aCreate)
			this.resultsTarget.appendChild(liCreate)
		}

		// Mensaje informativo
		const li = document.createElement("li")
		li.innerHTML = `<span class="text-gray-500 italic cursor-default pointer-events-none">No se encontraron resultados</span>`
		this.resultsTarget.appendChild(li)
		this.resultsTarget.classList.remove("hidden")
	}

	createRecord(text) {
		const nombre = (text || "").trim()
		if (nombre.length === 0) return

		if (this.hasLoadingTarget) this.loadingTarget.classList.remove("hidden")

		const token = document
			.querySelector('meta[name="csrf-token"]')
			?.getAttribute("content")

		fetch(this.createUrlValue, {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
				"Accept": "application/json",
				...(token ? { "X-CSRF-Token": token } : {})
			},
			body: JSON.stringify({ nombre })
		})
			.then(async (response) => {
				const data = await response.json().catch(() => ({}))
				if (!response.ok) {
					throw new Error(data.error || "No se pudo crear el registro")
				}
				return data
			})
			.then((item) => {
				// Esperamos {id, text}
				if (item && item.id) {
					this.select(item)
				} else {
					this.selectTextOnly(nombre)
				}
			})
			.catch((error) => {
				console.error("Error creando registro:", error)
				if (error?.message) window.alert(error.message)
				// Fallback: dejar el texto sin ID
				this.selectTextOnly(nombre)
			})
			.finally(() => {
				if (this.hasLoadingTarget) this.loadingTarget.classList.add("hidden")
			})
	}

	select(item) {
		this.inputTarget.value = item.text

		if (this.hasHiddenTarget) {
			this.hiddenTarget.value = item.id
			this.hiddenTarget.dispatchEvent(new Event('change'))
		}

		this.resultsTarget.classList.add("hidden")

		this.element.dispatchEvent(new CustomEvent('autocomplete:select', {
			detail: item,
			bubbles: true
		}))
	}

	selectTextOnly(text) {
		this.inputTarget.value = text

		if (this.hasHiddenTarget) {
			this.hiddenTarget.value = ""
			this.hiddenTarget.dispatchEvent(new Event('change'))
		}

		this.resultsTarget.classList.add("hidden")

		this.element.dispatchEvent(new CustomEvent('autocomplete:select', {
			detail: { id: null, text },
			bubbles: true
		}))
	}

	escapeHtml(str) {
		return String(str)
			.replaceAll("&", "&amp;")
			.replaceAll("<", "&lt;")
			.replaceAll(">", "&gt;")
			.replaceAll('"', "&quot;")
			.replaceAll("'", "&#039;")
	}

	hide(event) {
		if (!this.element.contains(event.target)) {
			this.resultsTarget.classList.add("hidden")
		}
	}
}
