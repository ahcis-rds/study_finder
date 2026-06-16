require 'rails_helper'

# Tests the keyword typeahead on the search/refine forms.
#
# The typeahead Stimulus controller uses @github/combobox-nav.
# It queries GET /studies/typeahead?q=<term> and renders suggestions as
# a <ul class="typeahead-list"> with <li class="typeahead-option"> items.
# These specs verify the full round-trip including the JS controller,
# the JSON endpoint, and the Elasticsearch completion suggester.
RSpec.describe "Typeahead", type: :system, js: true do
  def typeahead_input
    find('input[data-controller="typeahead"]', match: :first)
  end

  before do
    SystemInfo.delete_all
    create(:system_info, captcha: false)
  end

  describe "keyword completion on the studies index page" do
    before do
      # The keyword_suggest field is populated from brief_title keywords at
      # index time.  Create trials whose titles will seed the suggester.
      @diabetes = create(:trial, brief_title: "Diabetes Prevention Program",
                                 visible: true, approved: true)
      @dialysis = create(:trial, brief_title: "Dialysis Management Study",
                                 visible: true, approved: true)
      @asthma   = create(:trial, brief_title: "Asthma Control Trial",
                                 visible: true, approved: true)

      TrialKeyword.create!(trial_id: @diabetes.id, keyword: 'diabetes')
      TrialKeyword.create!(trial_id: @dialysis.id, keyword: 'dialysis')
      TrialKeyword.create!(trial_id: @asthma.id, keyword: 'asthma')

      es_index(@diabetes, @dialysis, @asthma)
    end

    it "does not show suggestions until the minimum character threshold is met" do
      visit studies_path
      typeahead_input.set('d')   # below minLength of 2
      expect(page).not_to have_css('.typeahead-option')
    end

    it "shows a dropdown of suggestions once the threshold is met" do
      visit studies_path
      typeahead_input.set('di')

      # wait for the debounce + fetch + render
      expect(page).to have_css('.typeahead-option', wait: 5)
    end

    it "suggestion items contain text matching the typed prefix" do
      visit studies_path
      typeahead_input.set('diab')

      expect(page).to have_css('.typeahead-option', wait: 5)

      suggestion_texts = all('.typeahead-option').map(&:text)
      expect(suggestion_texts).to all(match(/diab/i))
    end

    it "populates the input and hides the dropdown when a suggestion is clicked" do
      visit studies_path
      typeahead_input.set('diab')
      expect(page).to have_css('.typeahead-option', wait: 5)

      first('.typeahead-option').click

      expect(typeahead_input.value).to match(/diab/i)
      expect(page).to have_no_css('.typeahead-option')
    end

    it "hides the dropdown when Escape is pressed" do
      visit studies_path
      typeahead_input.set('diab')
      expect(page).to have_css('.typeahead-option', wait: 5)

      typeahead_input.send_keys(:escape)

      expect(page).to have_no_css('.typeahead-option')
    end

    it "navigates suggestions with arrow keys and selects with Enter" do
      visit studies_path
      typeahead_input.set('di')
      expect(page).to have_css('.typeahead-option', wait: 5)

      typeahead_input.send_keys(:arrow_down)   # highlight first item
      typeahead_input.send_keys(:enter)        # select it; submits form

      expect(typeahead_input.value).not_to be_empty
      expect(page).to have_no_css('.typeahead-option')
    end

    it "hides the dropdown when clicking outside the input" do
      visit studies_path
      typeahead_input.set('di')
      expect(page).to have_css('.typeahead-option', wait: 5)

      find('body').click

      expect(page).to have_no_css('.typeahead-option')
    end
  end
end
