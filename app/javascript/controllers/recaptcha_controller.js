import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    siteKey: String
  }

  connect() {
    this.attempts = 0
    this.maxAttempts = 80
    this.renderIfReady()
  }

  renderIfReady() {
    if (!this.hasSiteKeyValue || this.element.dataset.recaptchaWidgetId) {
      return
    }

    if (window.grecaptcha && typeof window.grecaptcha.render === "function") {
      const widgetId = window.grecaptcha.render(this.element, { sitekey: this.siteKeyValue })
      this.element.dataset.recaptchaWidgetId = String(widgetId)
      return
    }

    this.ensureScriptTag()

    this.attempts += 1
    if (this.attempts < this.maxAttempts) {
      window.setTimeout(() => this.renderIfReady(), 200)
    }
  }

  ensureScriptTag() {
    if (document.querySelector("script[data-recaptcha-script='true']")) {
      return
    }

    const script = document.createElement("script")
    script.src = "https://www.google.com/recaptcha/api.js?render=explicit"
    script.async = true
    script.defer = true
    script.dataset.recaptchaScript = "true"
    document.head.appendChild(script)
  }
}
