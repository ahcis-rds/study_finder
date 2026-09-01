require 'rails_helper'

# Tests JS-driven interactions on the studies pages:
#   - eligibility expand/collapse (study-results Stimulus controller)
#   - email-me and contact-study-team modals (Bootstrap + Stimulus)
#   - study show page rendering
RSpec.describe "Study interactions", type: :system, js: true do
  before do
    SystemInfo.delete_all
    create(:system_info,
      display_study_show_page: true,
      captcha: false   # disable reCAPTCHA in tests so modal forms are submittable
    )
  end

  # -----------------------------------------------------------------------
  # Eligibility expand / collapse
  # -----------------------------------------------------------------------
  describe "eligibility criteria toggle" do
    before do
      @trial = create(:trial,
        brief_title: "Toggle Eligibility Study",
        eligibility_criteria: "Inclusion Criteria:\n- Must be 18+\nExclusion Criteria:\n- Prior surgery",
        visible: true, approved: true
      )
      es_index(@trial)
    end

    it "eligibility criteria are hidden by default" do
      visit studies_path(search: { q: @trial.system_id })
      expect(page).to have_css('.btn-show-full-eligibility')
      expect(page).to have_css('.eligibility-criteria.d-none', visible: :hidden)
    end

    it "expands eligibility when the show button is clicked" do
      visit studies_path(search: { q: @trial.system_id })
      find('.btn-show-full-eligibility').click

      expect(page).to have_css('.eligibility-criteria:not(.d-none)', wait: 3)
      expect(page).to have_css('.btn-hide-full-eligibility:not(.d-none)', wait: 3)
      expect(page).to have_css('.btn-show-full-eligibility.d-none', visible: :hidden)
    end

    it "collapses eligibility when the hide button is clicked" do
      visit studies_path(search: { q: @trial.system_id })
      find('.btn-show-full-eligibility').click
      expect(page).to have_css('.eligibility-criteria:not(.d-none)', wait: 3)

      find('.btn-hide-full-eligibility').click
      expect(page).to have_css('.eligibility-criteria.d-none', wait: 3, visible: :hidden)
    end
  end

  # -----------------------------------------------------------------------
  # Email-me modal
  # -----------------------------------------------------------------------
  describe "email-me modal" do
    before do
      @trial = create(:trial, brief_title: "Email Modal Study",
                               visible: true, approved: true)
      es_index(@trial)
    end

    it "opens the email-me modal when the Share via email button is clicked" do
      visit studies_path(search: { q: @trial.system_id })

      find('.btn-email-me', match: :first).click

      expect(page).to have_css('#email-me-modal.show', wait: 3)
      expect(page).to have_content('Email this study information to me')
    end

    it "pre-fills the study title in the modal" do
      visit studies_path(search: { q: @trial.system_id })
      find('.btn-email-me', match: :first).click

      expect(page).to have_css('#email-me-modal.show', wait: 3)
      within('#email-me-modal') do
        expect(page).to have_content(@trial.brief_title)
      end
    end

    it "renders a close control wired for bootstrap dismiss" do
      visit studies_path(search: { q: @trial.system_id })
      find('.btn-email-me', match: :first).click
      expect(page).to have_css('#email-me-modal.show', wait: 3)

      dismiss_selector = '#email-me-modal button[data-bs-dismiss="modal"]'
      expect(page).to have_css(dismiss_selector)
    end
  end

  # -----------------------------------------------------------------------
  # Study show page
  # -----------------------------------------------------------------------
  describe "study show page" do
    before do
      @trial = create(:trial,
        brief_title: "Show Page Study",
        overall_status: "Recruiting",
        visible: true, approved: true
      )
      es_index(@trial)
    end

    it "renders the show page without error" do
      visit study_path(@trial)
      expect(page).to have_css('body')
      expect(page).to have_content(@trial.brief_title)
    end

    it "does not expose JS errors on the show page" do
      visit study_path(@trial)
      # allow a brief settle for Stimulus controller connect()
      sleep 0.5

      browser_errors = page.driver.browser.logs.get(:browser).select do |e|
        next false unless e.level == 'SEVERE'
        next false if e.message =~ /favicon/
        next false if e.message =~ /fonts\.googleapis\.com/ && e.message =~ /ERR_NAME_NOT_RESOLVED/
        next false if e.message =~ /googletagmanager\.com/ && e.message =~ /ERR_NAME_NOT_RESOLVED/

        true
      end

      expect(browser_errors).to be_empty,
        "Unexpected browser console errors:\n#{browser_errors.map(&:message).join("\n")}"
    end
  end
end
