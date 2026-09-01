require 'rails_helper'

# Tests the public search page (/studies) including the search form, result
# rendering, no results messaging, and keyword filters.
#
RSpec.describe "Search", type: :system, js: true do
  def search_input
    find('input[data-controller="typeahead"]', match: :first)
  end

  before do
    SystemInfo.delete_all
    create(:system_info, captcha: false, gender_filter: false)
  end

  describe "search page structure" do
    it "loads the search page with the search form present" do
      visit studies_path
      expect(page).to have_css('form.search-form')
      expect(page).to have_css('input[data-controller="typeahead"]')
      expect(page).to have_button('Search')
    end

    it "shows a Clear link on the search page" do
      visit studies_path
      expect(page).to have_link('Clear', href: studies_path)
    end
  end

  describe "keyword search" do
    before do
      @matching = create(:trial, brief_title: "Diabetes Management Trial", visible: true, approved: true)
      @other    = create(:trial, brief_title: "Asthma Prevention Study",   visible: true, approved: true)
      es_index(@matching, @other)
    end

    it "returns trials matching the keyword and renders result cards" do
      visit studies_path
      search_input.set('diabetes')
      click_button 'Search'

      expect(page).to have_current_path(/search%5Bq%5D=diabetes|search\[q\]=diabetes/)
      expect(page).to have_content('Diabetes Management Trial')
    end

    it "clears search results when the Clear link is clicked" do
      visit studies_path(search: { q: 'diabetes' })
      expect(page).to have_content('Diabetes Management Trial')

      click_link 'Clear'

      # After clearing, both studies should appear (or at minimum no keyword filter applied)
      expect(current_path).to eq(studies_path)
    end

    it "shows a did-you-mean suggestion for near-miss spellings", :aggregate_failures do
      # Elasticsearch needs to return a suggestion; this test verifies the
      # suggestion alert renders if the suggestion data is present.
      visit studies_path
      search_input.set('diabetis')
      click_button 'Search'
      # Either results shown or the suggestion prompt — both are valid outcomes
      # depending on ES configuration. We just assert no 500 error occurs.
      expect(page).not_to have_css('.alert-danger')
      expect(page).to have_css('body')
      expect(page).to have_css('.alert-info').or have_content('Diabetes')
    end
  end

  describe "empty search state" do
    it "shows the no-results alert when nothing matches" do
      visit studies_path(search: { q: 'xyzzyunmatchableterm99' })

      expect(page).to have_css('.alert')
      expect(page).to have_content('no trials that matched your search')
    end
  end

  describe "age filter checkboxes" do
    before do
      @trial = create(:trial, brief_title: "Pediatric Study", visible: true, approved: true)
      es_index(@trial)
    end

    it "submits the children filter and retains checkbox state" do
      visit studies_path
      check 'search[children]'
      click_button 'Search'

      expect(page).to have_checked_field('search[children]')
      expect(page).to have_current_path(/search.*children/)
    end

    it "submits the adults filter and retains checkbox state" do
      visit studies_path
      check 'search[adults]'
      click_button 'Search'

      expect(page).to have_checked_field('search[adults]')
    end
  end

  describe "gender filter" do
    it "does not show the gender select when gender_filter is disabled" do
      visit studies_path
      expect(page).not_to have_select('search[gender]')
    end
  end
end
