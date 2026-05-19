import { Controller } from "@hotwired/stimulus"

// Formats cédula input as 000-000000-0000X while typing,
// but strips dashes before form submit so DB stores raw value.
export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.inputTarget.addEventListener("input", this._onInput)
    this.inputTarget.addEventListener("keydown", this._onKeydown)

    // Format existing value (e.g. when editing)
    if (this.inputTarget.value) {
      this.inputTarget.value = this._format(this.inputTarget.value)
    }

    // Find parent form and strip dashes before submit
    this._form = this.inputTarget.closest("form")
    if (this._form) {
      this._form.addEventListener("submit", this._onSubmit)
    }
  }

  disconnect() {
    this.inputTarget.removeEventListener("input", this._onInput)
    this.inputTarget.removeEventListener("keydown", this._onKeydown)
    if (this._form) {
      this._form.removeEventListener("submit", this._onSubmit)
    }
  }

  // Strip dashes, keep only digits and uppercase letters
  _raw(value) {
    return value.replace(/[^0-9A-Z]/gi, "").toUpperCase()
  }

  // Format raw value as 000-000000-0000X
  _format(value) {
    const raw = this._raw(value)
    let result = ""

    for (let i = 0; i < raw.length && i < 14; i++) {
      if (i === 3 || i === 9) result += "-"
      result += raw[i]
    }

    return result
  }

  _onInput = (e) => {
    const input = e.target
    const cursorPos = input.selectionStart
    const oldVal = input.value
    const newVal = this._format(oldVal)

    input.value = newVal

    // Adjust cursor position after formatting
    const rawBefore = this._raw(oldVal.substring(0, cursorPos)).length
    let newCursor = 0
    let rawCount = 0
    for (let i = 0; i < newVal.length; i++) {
      if (newVal[i] !== "-") rawCount++
      if (rawCount >= rawBefore) {
        newCursor = i + 1
        break
      }
    }
    if (rawCount < rawBefore) newCursor = newVal.length

    input.setSelectionRange(newCursor, newCursor)
  }

  _onKeydown = (e) => {
    const input = e.target
    // Allow backspace to skip over dashes
    if (e.key === "Backspace") {
      const pos = input.selectionStart
      if (pos > 0 && input.value[pos - 1] === "-") {
        e.preventDefault()
        input.value = input.value.substring(0, pos - 2) + input.value.substring(pos)
        input.value = this._format(input.value)
        const newPos = Math.max(0, pos - 2)
        input.setSelectionRange(newPos, newPos)
      }
    }
  }

  // Strip dashes before form submits
  _onSubmit = () => {
    this.inputTarget.value = this._raw(this.inputTarget.value)
  }
}
