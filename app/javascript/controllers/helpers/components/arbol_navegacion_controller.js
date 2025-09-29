import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["module"]

    open(event) {
        this.moduleTargets.forEach(el => el.classList.remove("menu-active"))
        event.currentTarget.classList.add("menu-active")
    }
}
