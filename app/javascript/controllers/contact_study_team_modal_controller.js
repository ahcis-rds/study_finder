import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  static targets = ["form", "submit", "studyEmail", "email", "name", "phone", "notes"]
  static values = { endpoint: { type: String, default: "/studies/contact_team" } }

  connect() {
    this.triggerElement = null
    this.boundShowHandler = this.onShow.bind(this)
    this.element.addEventListener("show.bs.modal", this.boundShowHandler)
  }

  disconnect() {
    this.element.removeEventListener("show.bs.modal", this.boundShowHandler)
  }

  onShow(event) {
    this.triggerElement = event.relatedTarget
    if (!this.triggerElement) return

    const { email, trialId } = this.triggerElement.dataset
    this.studyEmailTarget.textContent = email || ""
    this.studyEmailTarget.href = `mailto:${email}?bcc=${window.STUDY_CONTACT_BCC || ""}`
    this.submitTarget.dataset.trialId = trialId || ""

    this.resetCaptchaIfPresent()
  }

  submit(event) {
    event.preventDefault()

    const trialId = this.submitTarget.dataset.trialId
    const email = this.emailTarget.value.trim()
    const name = this.nameTarget.value.trim()

    this.clearValidationState()

    if (!email) {
      this.emailTarget.setCustomValidity("Please provide your email.")
      this.emailTarget.reportValidity()
      return
    }

    if (!name) {
      this.nameTarget.setCustomValidity("Please provide your name.")
      this.nameTarget.reportValidity()
      return
    }

    this.emailTarget.setCustomValidity("")
    this.nameTarget.setCustomValidity("")

    const captchaResponse = this.captchaResponse()
    if (this.hasCaptchaElement() && !captchaResponse) {
      this.appendValidationMessage(this.captchaElement(), "Please complete the captcha.")
      return
    }

    const payload = new URLSearchParams({
      id: trialId,
      to: this.studyEmailTarget.textContent,
      name,
      email,
      phone: this.phoneTarget.value,
      notes: this.notesTarget.value
    })

    if (captchaResponse) {
      payload.set("g-recaptcha-response", captchaResponse)
    }

    fetch(this.endpointValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": this.csrfToken(),
        "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
      },
      body: payload.toString()
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error("Contact request failed")
        }

        this.formTarget.reset()
        this.hideModal()
        this.showAlert("success", "Your email has been sent!")
        this.track("email_study_team", "sent", { trial_id: trialId })
      })
      .catch(() => {
        this.formTarget.reset()
        this.hideModal()
        this.showAlert("danger", "There was a problem sending your email")
      })
  }

  hideModal() {
    const modal = Modal.getOrCreateInstance(this.element)
    modal.hide()
  }

  csrfToken() {
    const tag = document.querySelector("meta[name='csrf-token']")
    return tag ? tag.getAttribute("content") : ""
  }

  resetCaptchaIfPresent() {
    const captchaEl = this.captchaElement()
    if (!captchaEl) return

    const widgetId = captchaEl.dataset.recaptchaWidgetId
    if (widgetId && window.grecaptcha && typeof window.grecaptcha.reset === "function") {
      window.grecaptcha.reset(Number(widgetId))
    }
  }

  captchaResponse() {
    const captchaEl = this.captchaElement()
    if (!captchaEl) return ""

    const widgetId = captchaEl.dataset.recaptchaWidgetId
    if (!widgetId || !window.grecaptcha || typeof window.grecaptcha.getResponse !== "function") {
      return ""
    }

    return window.grecaptcha.getResponse(Number(widgetId))
  }

  hasCaptchaElement() {
    return !!this.captchaElement()
  }

  captchaElement() {
    return this.element.querySelector("#study-team-captcha")
  }

  clearValidationState() {
    this.emailTarget.setCustomValidity("")
    this.nameTarget.setCustomValidity("")
    this.formTarget.querySelectorAll(".js-validation-message").forEach((node) => node.remove())
  }

  appendValidationMessage(container, message) {
    const help = document.createElement("div")
    help.className = "js-validation-message text-danger small mt-1"
    help.textContent = message
    container.appendChild(help)
  }

  showAlert(kind, message) {
    if (!this.triggerElement) return

    const alert = document.createElement("div")
    alert.className = `alert alert-${kind} alert-dismissible mt-2`
    alert.setAttribute("role", "alert")
    alert.innerHTML = `${message}<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>`

    const parent = this.triggerElement.parentElement
    parent.insertAdjacentElement("afterend", alert)
  }

  track(category, action, data = {}) {
    if (typeof window.track === "function") {
      window.track("send", "event", category, action, data)
    }
  }
}
