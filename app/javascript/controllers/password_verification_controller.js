import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "password", "confirmation" ]

  validate(event) {
    const password = this.passwordTarget.value
    const confirmation = this.confirmationTarget.value

    // Si ambos están vacíos, permitimos enviar (en caso de edición)
    if (password === "" && confirmation === "") {
      return
    }

    if (password !== confirmation) {
      event.preventDefault()
      alert("Las contraseñas no coinciden. Por favor, verifíquelas.")
    }
  }
}
