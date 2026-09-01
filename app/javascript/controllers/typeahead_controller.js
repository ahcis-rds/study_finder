import { Controller } from "@hotwired/stimulus"
import Combobox from "@github/combobox-nav"

export default class extends Controller {
  static values = {
    url: { type: String, default: "/studies/typeahead" },
    minLength: { type: Number, default: 2 },
    delay: { type: Number, default: 250 }
  }

  connect() {
    this.form = this.element.closest("form")
    this.boundOnInput = this.onInput.bind(this)
    this.boundOnKeydown = this.onKeydown.bind(this)
    this.boundOnCommit = this.onCommit.bind(this)
    this.debounceTimer = null

    this.list = document.createElement("ul")
    this.list.hidden = true
    this.list.className = "typeahead-list"
    this.list.setAttribute("role", "listbox")
    this.list.id = `typeahead-list-${Math.random().toString(36).slice(2, 10)}`

    const parent = this.element.parentElement || this.element
    parent.classList.add("position-relative")
    parent.appendChild(this.list)

    this.combobox = new Combobox(this.element, this.list, {
      tabInsertsSuggestions: false,
      firstOptionSelectionMode: "none"
    })

    this.element.addEventListener("input", this.boundOnInput)
    this.element.addEventListener("keydown", this.boundOnKeydown)
    this.list.addEventListener("combobox-commit", this.boundOnCommit)
  }

  disconnect() {
    clearTimeout(this.debounceTimer)

    this.element.removeEventListener("input", this.boundOnInput)
    this.element.removeEventListener("keydown", this.boundOnKeydown)
    this.list.removeEventListener("combobox-commit", this.boundOnCommit)

    if (this.combobox) {
      this.combobox.destroy()
      this.combobox = null
    }

    if (this.list) {
      this.list.remove()
      this.list = null
    }
  }

  onInput(event) {
    const query = event.target.value.trim()

    clearTimeout(this.debounceTimer)
    if (query.length < this.minLengthValue) {
      this.clearSuggestions()
      return
    }

    this.debounceTimer = setTimeout(() => {
      this.fetchSuggestions(query)
        .then((items) => this.renderSuggestions(items))
        .catch(() => this.clearSuggestions())
    }, this.delayValue)
  }

  onKeydown(event) {
    if (event.key !== "Enter") return

    const selectedOption = this.list.querySelector('[aria-selected="true"]')
    if (selectedOption) {
      event.preventDefault()
      this.commitOption(selectedOption)
      if (this.form) this.form.requestSubmit()
    }
  }

  onCommit(event) {
    this.commitOption(event.target)
  }

  commitOption(option) {
    const value = option?.dataset?.value || option?.textContent || ""
    this.element.value = value.trim()
    this.clearSuggestions()
  }

  renderSuggestions(items) {
    this.clearSuggestions()
    if (!Array.isArray(items) || items.length === 0) return

    const fragment = document.createDocumentFragment()
    items.forEach((item, index) => {
      const option = document.createElement("li")
      option.id = `${this.list.id}-option-${index}`
      option.setAttribute("role", "option")
      option.dataset.value = item.value
      option.textContent = item.label
      option.className = "typeahead-option"
      fragment.appendChild(option)
    })

    this.list.appendChild(fragment)
    this.list.hidden = false
    this.combobox.start()
  }

  clearSuggestions() {
    if (!this.list) return
    this.list.hidden = true
    this.list.innerHTML = ""
    if (this.combobox) this.combobox.stop()
  }

  fetchSuggestions(query) {
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("q", query)

    return fetch(url.toString())
      .then((response) => {
        if (!response.ok) {
          throw new Error("Typeahead request failed")
        }
        return response.json()
      })
      .then((data) => {
        if (!Array.isArray(data)) {
          return []
        }
        return data
          .filter((item) => typeof item === "string")
          .map((item) => ({ value: item, label: item }))
      })
  }
}
