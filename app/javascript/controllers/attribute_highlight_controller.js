import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    selector: String,
    className: String,
    childSelector: String
  }

  connect() {
    if (!this.hasSelectorValue || !this.hasClassNameValue) {
      return
    }

    const targets = Array.from(document.querySelectorAll(this.selectorValue))
    targets.forEach((node) => {
      if (this.hasChildSelectorValue) {
        const child = node.querySelector(this.childSelectorValue)
        if (child) {
          child.className = `${child.className} ${this.classNameValue}`.trim()
        }
      } else {
        node.className = `${node.className} ${this.classNameValue}`.trim()
      }
    })
  }
}
