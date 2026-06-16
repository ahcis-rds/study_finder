import { Controller } from "@hotwired/stimulus"
import TomSelect      from "tom-select"

// Connects to data-controller="ts--select"
export default class extends Controller {
  static values = { max: Number }

  connect() {
    const itemsMax = this.resolvedMaxItems()

    this.tom = new TomSelect(this.element, {
      maxItems: itemsMax,
      maxOptions: null,
      plugins: this.element.multiple ? { remove_button: { title: "Remove this item" } } : {}
    })

    this.element.classList.add('d-none')
    this.element.setAttribute("aria-labelledby", `${this.element.id}-ts-label`)
  }

  resolvedMaxItems() {
    if (!this.element.multiple) {
      return 1
    }

    if (this.hasMaxValue && Number.isFinite(this.maxValue) && this.maxValue > 0) {
      return this.maxValue
    }

    return null
  }

  disconnect() {
    if (this.tom) {
      this.tom.destroy()
      this.tom = null
    }
  }
}
