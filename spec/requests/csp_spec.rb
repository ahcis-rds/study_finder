require 'rails_helper'

# Verifies the Content-Security-Policy header emitted by the application.
#
# The CSP is configured in config/initializers/content_security_policy.rb.
# Key invariants:
#   - unsafe-inline is present in script-src and style-src (required because
#     several views use inline scripts/styles and the nonce generator is off)
#   - nonce-'' (empty nonce token) must NOT appear — its presence would
#     silently invalidate unsafe-inline in compliant browsers
#   - object-src is 'none' to block plugin execution
#   - Expected external origins (reCAPTCHA) are whitelisted
RSpec.describe "Content Security Policy", type: :request do
  before { create(:system_info) }

  let(:csp_header) do
    get root_path
    response.headers['Content-Security-Policy']
  end

  it "emits a Content-Security-Policy header" do
    expect(csp_header).to be_present
  end

  describe "script-src directive" do
    it "includes 'unsafe-inline' so inline scripts are permitted" do
      expect(csp_header).to include("script-src")
      expect(csp_header).to include("'unsafe-inline'")
    end

    it "does not contain an empty nonce token ('nonce-')" do
      # An empty nonce token causes browsers to ignore 'unsafe-inline',
      # blocking all inline scripts. This was the root cause of the CSP
      # breakage discovered during the jQuery→Stimulus migration.
      expect(csp_header).not_to include("'nonce-'")
    end

    it "whitelists Google reCAPTCHA script origins" do
      expect(csp_header).to include("https://www.google.com/recaptcha/")
      expect(csp_header).to include("https://www.gstatic.com/recaptcha/")
    end
  end

  describe "style-src directive" do
    it "includes 'unsafe-inline' so inline styles are permitted" do
      expect(csp_header).to include("style-src")
      # unsafe-inline appears once in the script-src; assert it appears
      # in a style-src context by checking for the style-src fragment.
      style_src = csp_header.split(';').find { |d| d.strip.start_with?('style-src') }
      expect(style_src).to include("'unsafe-inline'")
    end
  end

  describe "object-src directive" do
    it "sets object-src to 'none' to block plugin execution" do
      object_src = csp_header.split(';').find { |d| d.strip.start_with?('object-src') }
      expect(object_src).to be_present
      expect(object_src).to include("'none'")
    end
  end

  describe "default-src directive" do
    it "restricts default-src to self and https" do
      default_src = csp_header.split(';').find { |d| d.strip.start_with?('default-src') }
      expect(default_src).to be_present
      expect(default_src).to include("'self'")
      expect(default_src).to include("https:")
    end
  end

  describe "CSP on the studies search page" do
    it "emits a CSP header on the studies index" do
      get studies_path
      expect(response.headers['Content-Security-Policy']).to be_present
    end
  end
end
