import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
	static targets = ["module"]

	connect() {
		// Bind methods so we can remove listeners later
		this._onTurboLoad = this.updateActive.bind(this)
		this._onPopState = this.updateActive.bind(this)
	}
	open(event) {
		this.moduleTargets.forEach(el => el.classList.remove("menu-active"))
		event.currentTarget.classList.add("menu-active")
	}
}
