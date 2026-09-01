import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "form"]

  connect() {
    const source = window.localStorage.getItem("utm_source")
    if (source) {
      this.inputTarget.value = source
    }

    this.boundSubmit = this.handleSubmit.bind(this)
    this.formTarget.addEventListener("submit", this.boundSubmit)
  }

  disconnect() {
    this.formTarget.removeEventListener("submit", this.boundSubmit)
  }

  handleSubmit() {
    window.localStorage.setItem("utm_source", this.inputTarget.value)
  }
}
