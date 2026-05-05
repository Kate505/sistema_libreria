import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // ─── Page fade-in on navigation (turbo:render) ───────────────────────
    this.boundFadeIn = this._triggerFadeIn.bind(this)
    document.addEventListener("turbo:render", this.boundFadeIn)

    // ─── Form submit spinner (create / update / delete) ──────────────────
    this.boundFormSubmit = this._onFormSubmit.bind(this)
    document.addEventListener("turbo:submit-start", this.boundFormSubmit)

    this.boundFormEnd = this._onFormEnd.bind(this)
    document.addEventListener("turbo:submit-end", this.boundFormEnd)
  }

  disconnect() {
    document.removeEventListener("turbo:render",       this.boundFadeIn)
    document.removeEventListener("turbo:submit-start", this.boundFormSubmit)
    document.removeEventListener("turbo:submit-end",   this.boundFormEnd)
  }

  // ─── Private ─────────────────────────────────────────────────────────────

  _triggerFadeIn() {
    const mainContent = document.getElementById("main_content")
    if (mainContent) {
      mainContent.classList.remove("content-fade-in")
      void mainContent.offsetWidth           // force reflow so animation restarts
      mainContent.classList.add("content-fade-in")
    }
  }

  _onFormSubmit(event) {
    const form = event.detail?.formSubmission?.formElement
    if (!form) return

    const submitBtn = form.querySelector("[type='submit']")
    if (!submitBtn) return

    // Store original label so we can restore it on end
    submitBtn.dataset.originalHtml = submitBtn.innerHTML

    submitBtn.disabled = true
    submitBtn.innerHTML =
      `<span class="loading loading-spinner loading-sm"></span>`
  }

  _onFormEnd(event) {
    const form = event.detail?.formSubmission?.formElement
    if (!form) return

    const submitBtn = form.querySelector("[type='submit']")
    if (!submitBtn) return

    // Restore original label and re-enable (Turbo will redirect on success anyway)
    if (submitBtn.dataset.originalHtml !== undefined) {
      submitBtn.innerHTML = submitBtn.dataset.originalHtml
      delete submitBtn.dataset.originalHtml
    }
    submitBtn.disabled = false
  }
}
