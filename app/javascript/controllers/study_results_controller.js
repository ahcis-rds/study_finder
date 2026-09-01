import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  showLocations(event) {
    const study = this.studyElement(event)
    const locations = study?.querySelector(".study-locations")

    if (locations) {
      locations.classList.remove("d-none")
    }
  }

  hideLocations(event) {
    const locations = event.currentTarget.closest(".study-locations")

    if (locations) {
      locations.classList.add("d-none")
    }
  }

  showEligibility(event) {
    const study = this.studyElement(event)
    if (!study) return

    const showButton = study.querySelector(".btn-show-full-eligibility")
    const hideButton = study.querySelector(".btn-hide-full-eligibility")
    const criteria = study.querySelector(".eligibility-criteria")

    showButton?.classList.add("d-none")
    hideButton?.classList.remove("d-none")
    criteria?.classList.remove("d-none")
  }

  hideEligibility(event) {
    const study = this.studyElement(event)
    if (!study) return

    const showButton = study.querySelector(".btn-show-full-eligibility")
    const hideButton = study.querySelector(".btn-hide-full-eligibility")
    const criteria = study.querySelector(".eligibility-criteria")

    hideButton?.classList.add("d-none")
    showButton?.classList.remove("d-none")
    criteria?.classList.add("d-none")
  }

  markReindexing(event) {
    event.currentTarget.textContent = "Indexing... Please Wait."
  }

  studyElement(event) {
    return event.currentTarget.closest("[data-study-id]")
  }
}
