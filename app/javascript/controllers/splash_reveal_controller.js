import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image"]

  connect() {
    const delays = [1000, 1500, 1300, 2700]

    this.imageTargets.forEach((image, index) => {
      const delay = delays[index] || 1000
      window.setTimeout(() => {
        image.classList.add("reveal")
      }, delay)
    })
  }
}
