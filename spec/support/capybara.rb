# frozen_string_literal: true

require 'capybara-playwright-driver'

Capybara.register_driver :playwright do |app|
  Capybara::Playwright::Driver.new(
    app,
    browser_type: :chromium,
    headless: true,
    viewport: { width: 1920, height: 1080 }
  )
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :playwright
Capybara.server = :puma, { Silent: true }
Capybara.default_max_wait_time = 5
