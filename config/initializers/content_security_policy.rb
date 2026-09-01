# Be sure to restart your server when you modify this file.
#
# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html\#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src :self, :https, :data
    policy.img_src :self, :https, :data
    policy.object_src :none

    # reCAPTCHA: allow loader/runtime scripts, iframes, and API calls.
    policy.script_src :self, :https, :unsafe_inline,
      "https://www.google.com/recaptcha/",
      "https://www.gstatic.com/recaptcha/"
    policy.frame_src :self, :https,
      "https://www.google.com/recaptcha/",
      "https://www.gstatic.com/recaptcha/"
    policy.connect_src :self, :https,
      "https://www.google.com/recaptcha/",
      "https://www.gstatic.com/recaptcha/"

    policy.style_src :self, :https, :unsafe_inline

    # Specify URI for violation reports.
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # This app currently uses inline script/style in legacy templates and analytics partials.
  # Keep nonce directives disabled so unsafe-inline remains effective.
  # config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  # config.content_security_policy_nonce_directives = %w[script-src style-src]

  # Automatically add `nonce` to `javascript_tag`, `javascript_include_tag`, and `stylesheet_link_tag`
  # if the corresponding directives are specified in `content_security_policy_nonce_directives`.
  # config.content_security_policy_nonce_auto = true

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
