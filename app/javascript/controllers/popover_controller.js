import { Controller } from "@hotwired/stimulus"
import { Popover } from "bootstrap"

export default class extends Controller {
  connect() {
    this.popover = new Popover(this.element, {
      trigger: "hover focus"
    })
  }

  disconnect() {
    if (this.popover) {
      this.popover.dispose()
      this.popover = null
    }
  }
}
