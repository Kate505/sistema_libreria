import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["launcher", "menus", "menusTitle", "menusContent"]

  connect() {
    this.launcher = document.getElementById("launcher")
    this.menus = document.getElementById("menus")
    this.menusTitle = document.getElementById("menus-title")
    this.menusContent = document.getElementById("menus-content")
  }

  open(event) {
    const moduleId = event.currentTarget.dataset.homeModuleId
    const moduleName = event.currentTarget.querySelector("span").innerText

    this.menusTitle.textContent = moduleName

    const menusHtml = document.getElementById(`menus-module-${moduleId}`)
    this.menusContent.innerHTML = menusHtml.innerHTML
    this.launcher.classList.add("hidden")
    this.menus.classList.remove("hidden")
  }

  back() {
    this.menus.classList.add("hidden")
    this.launcher.classList.remove("hidden")
  }
}
