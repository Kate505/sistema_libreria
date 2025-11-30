// javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
	static targets = ["module"]

	connect() {
		// Handlers that call updateActive only if it's defined — no .bind usage
		this._onTurboLoad = () => {
			try { if (typeof this.updateActive === "function") this.updateActive() } catch (e) { /* ignore */ }
		}
		this._onPopState = this._onTurboLoad

		// Initial run
		try { if (typeof this.updateActive === "function") this.updateActive() } catch (e) { /* ignore */ }

		document.addEventListener("turbo:load", this._onTurboLoad)
		window.addEventListener("popstate", this._onPopState)
	}

	disconnect() {
		document.removeEventListener("turbo:load", this._onTurboLoad)
		window.removeEventListener("popstate", this._onPopState)
	}

	updateActive() {
		this.moduleTargets.forEach(el => el.classList.remove("menu-active"))

		const currentPath = window.location.pathname
		let matched = null

		this.moduleTargets.forEach(el => {
			const href = el.getAttribute('href') || el.dataset.href || ''
			if (!href || href === '#') return
			try {
				const url = new URL(href, window.location.origin)
				const path = url.pathname
				if (path === currentPath || (path !== '/' && currentPath.startsWith(path))) {
					if (!matched || path.length > matched.path.length) matched = { el, path }
				}
			} catch (e) { /* ignore invalid URLs */ }
		})

		if (matched) {
			matched.el.classList.add("menu-active")
			const details = matched.el.closest('details')
			if (details) details.open = true
			let parent = details
			while (parent) {
				parent = parent ? parent.closest('details') : null
				if (parent) parent.open = true
			}
		}
	}
}
