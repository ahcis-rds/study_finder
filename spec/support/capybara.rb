require 'capybara/rspec'
require 'socket'

# JS system specs use a Selenium standalone Chrome container.
#
# The SELENIUM_URL env var lets you override the hub URL — useful when running
# tests from the host machine against a docker-compose stack:
#
#   SELENIUM_URL=http://localhost:4444 bundle exec rspec spec/system/
#
# When tests run *inside* a Docker container set SELENIUM_URL=http://selenium:4444
# (the Docker service name resolves on the shared network).
#
# The app itself is served by Capybara's built-in Puma server. The Selenium
# container must be able to reach it. When running inside Docker we bind
# Capybara's server to the container's own non-loopback IP (no DNS required)
# and point app_host at that same IP so Chrome can always reach it directly.
# Override with CAPYBARA_SERVER_HOST / CAPYBARA_APP_HOST env vars if needed.

SELENIUM_URL = ENV.fetch('SELENIUM_URL', 'http://localhost:4444')

Capybara.register_driver :selenium_chrome_remote do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--window-size=1400,900')

  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: "#{SELENIUM_URL}/wd/hub",
    options: options
  )
end

Capybara.javascript_driver  = :selenium_chrome_remote
Capybara.default_max_wait_time = 8
Capybara.server = :puma, { Silent: true }

# Resolve the IP the Selenium browser should use to reach this container.
# Prefer an explicit env var (hostname or IP). When running inside Docker
# without that var, discover our own non-loopback IPv4 address so Chrome can
# reach us without relying on Docker DNS resolution for 'docker compose run'
# containers (which can be unreliable from a separate Selenium container).
_capybara_host =
  if ENV['CAPYBARA_APP_HOST'].present?
    ENV['CAPYBARA_APP_HOST']
  elsif ENV['CAPYBARA_SERVER_HOST'].present? && ENV['CAPYBARA_SERVER_HOST'] != '0.0.0.0'
    ENV['CAPYBARA_SERVER_HOST']
  else
    Socket.ip_address_list
          .select { |a| a.ipv4? && !a.ipv4_loopback? }
          .map(&:ip_address)
          .first || '127.0.0.1'
  end

Capybara.server_host = _capybara_host
Capybara.app_host    = "http://#{_capybara_host}"

if ENV.fetch('CAPYBARA_NETWORK_DEBUG', '0') != '0'
  warn("[capybara-network] SELENIUM_URL=#{SELENIUM_URL} server_host=#{Capybara.server_host} app_host=#{Capybara.app_host}")
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_chrome_remote
  end

  # Use rack_test (no JS) for system specs explicitly tagged js: false.
  config.before(:each, type: :system, js: false) do
    driven_by :rack_test
  end
end
