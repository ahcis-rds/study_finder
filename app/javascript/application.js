// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"

// GA4-only analytics tracking. Called from legacy onclick attributes in templates.
window.track = function(event, category, data) {
  if (typeof gtag !== 'undefined') {
    gtag(event, category, data)
  }
}
