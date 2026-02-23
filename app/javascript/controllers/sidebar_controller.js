import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
	static targets = ["toggle"]

	expandAndOpen(event) {
		event?.preventDefault()
		event?.stopPropagation()

		const targetId =
			      event?.currentTarget?.dataset?.targetId ||
			      event?.currentTarget?.dataset?.target_id

		if (this.hasToggleTarget) {
			this.toggleTarget.checked = true
			this.toggleTarget.dispatchEvent(new Event("change", { bubbles: true }))
		}

		if (!targetId) return

		requestAnimationFrame(() => {
			this.openDetailsTree(targetId)
		})
	}

	openDetailsTree(targetId) {
		const detailsElement = document.getElementById(targetId)
		if (!detailsElement) return
		detailsElement.open = true

		let parent = detailsElement.closest("details")
		while (parent) {
			parent.open = true
			parent = parent.parentElement?.closest("details")
		}

		document.dispatchEvent(
			new CustomEvent("sidebar:expanded", {
				detail: { targetId }
			})
		)
	}
}
