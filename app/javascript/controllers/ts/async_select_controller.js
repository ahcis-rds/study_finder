import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

// Basic usage, where url = an endpoint that can return the desired set of options:
// data: {
//         controller: "ts--async-select",
//         ts__async_select_url_value: scheduling_projects_path
//       }

// Connects to data-controller="ts--async-select"
export default class extends Controller {
  static values = {
    url: { type: String, default: null }, // Include if an async call is required for fetching options
    maxItems: { type: Number, default: 1 }, // Default. Include in html if `multiple: true` is set on select element
    preselectedOptions: { type: Array, default: [] } // Include in html if tom-select is not identifying existing selected records
  }

  connect() {
    this.checkForRequiredAttribute()
    this.initTomSelect()

    // Hide the original select element from screen readers and apply an aria label in case it is still picked up
    this.element.classList.add('d-none')
    this.element.setAttribute("aria-hidden", "true")
    this.element.setAttribute("aria-labelledby", this.element.id + '-ts-label' )
  }

  disconnect() {
    if (this.select) {
      this.select.destroy()
    }
  }

  checkForRequiredAttribute() {
    this.isRequired = this.element.hasAttribute("required")

    if (this.isRequired) {
      // Remove `required: true` from hidden select to prevent form submission error about a required field not being focusable
      this.element.removeAttribute("required")
    }
  }

  initTomSelect() {
    this.select = new TomSelect(this.element, this.urlValue ? this.asyncConfig() : this.basicConfig())

    this.addPreselectedOptions()
    this.addAriaDescribedby()
    this.syncValidationState()
    this.setRequiredAttribute()
  }

  basicConfig() {
    return {
      maxItems: this.maxItemsValue,
      closeAfterSelect: true,
      plugins: {
        remove_button: {
          title: 'Remove this item',
        },
        caret_position: {} // Required to use keyboard to move between selected records.
      },
    }
  }

  asyncConfig() {
    return Object.assign(this.basicConfig(), {
      valueField: "id",
      labelField: "title",
      searchField: "title",
      loadThrottle: 300, // Delay in ms after user stops typing (debounce)
      onChange: (value) => {
        this.element.dispatchEvent(new Event("change", { bubbles: true })) // Using bubbles to mimic native behavior of input
      },
      render: {
        loading: (_data, _escape) => {
          return '<div class="spinner-border spinner-border-sm" role="status"><span class="visually-hidden" aria-live="polite">Loading...</span></div>'
        },
        no_results: (_data, _escape) => {
          return '<div class="ps-2" role="status" aria-live="polite">No results found</div>'
        }
      },
      load: (query, callback) => {
        if (!query.length) return callback()

        const url = new URL(this.urlValue, window.location.origin)
        url.searchParams.append("q", query)

        fetch(url.toString())
            .then(response => response.json())
            .then(json => { callback(json) })
            .catch(() => { callback() }) // Stops spinner on failure
      }
    })
  }

  addPreselectedOptions() {
    // Some async instances of this controller fail to show preselected options on initial load. This fixes that if `ts__async_select_preselected_options_value` was included.
    if (this.preselectedOptionsValue.length === 0) { return }

    this.preselectedOptionsValue.forEach(item => {
      // item expected to conform to { id: , title: }
      this.select.addOption(item)
      this.select.addItem(item.id)
    })
  }

  addAriaDescribedby() {
    const ariaDescribedby = this.element.getAttribute("aria-describedby")
    if (ariaDescribedby) {
      this.select.control_input.setAttribute("aria-describedby", ariaDescribedby)
    }
  }

  syncValidationState() {
    if (this.element.classList.contains("is-invalid")) {
      this.select.wrapper.classList.add("is-invalid")
    }

    if (this.element.getAttribute("aria-invalid") === "true") {
      this.select.control_input.setAttribute("aria-invalid", "true")
      this.select.control.setAttribute("aria-invalid", "true") // Adds to outer wrapper for more robust identification
    }
  }

  setRequiredAttribute() {
    if (!this.isRequired) return

    this.setNativeRequiredMessage()
    this.enforceOrClearRequiredMessage()

    this.select.on("change", () => {
      this.enforceOrClearRequiredMessage()
    })
  }

  setNativeRequiredMessage() {
    // Just ensures we get the correct message from the browser instead of hardcoding one.
    const dummy = document.createElement("select")
    dummy.required = true
    this.requiredMessage = dummy.validationMessage || "Please fill out this field."
  }

  enforceOrClearRequiredMessage() {
    if (this.select.items.length === 0) {
      this.select.control_input.setCustomValidity(this.requiredMessage)
    } else {
      this.select.control_input.setCustomValidity("")
    }
  }
}
