import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]

  connect() {
    const savedTheme = localStorage.getItem("theme") || "winter"
    this.applyTheme(savedTheme)
    this.checkboxTarget.checked = savedTheme === "night"
  }

  toggle() {
    const newTheme = this.checkboxTarget.checked ? "night" : "winter"
    this.applyTheme(newTheme)
    localStorage.setItem("theme", newTheme)
  }

  applyTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme)
  }
}
