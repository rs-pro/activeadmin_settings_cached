# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
unless File.exist?(File.expand_path('../examples/demo/app/assets/active_admin.css', __dir__))
  system('bundle', 'exec', 'rake', '-f', 'examples/demo/Rakefile', 'assets:build', exception: true)
end
require_relative '../examples/demo/config/environment'
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/cuprite'

ActiveRecord::MigrationContext.new(File.expand_path('../examples/demo/db/migrate', __dir__)).migrate

Capybara.register_driver :cuprite do |app|
  Capybara::Cuprite::Driver.new(app, browser_options: { 'no-sandbox': nil, 'disable-dev-shm-usage': nil },
                                    browser_path: ENV['CHROME_BIN'] || '/usr/bin/google-chrome-stable')
end
Capybara.javascript_driver = :cuprite
Capybara.server = :puma, { Silent: true }

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.before do
    Setting.delete_all
    Setting.clear_cache
  end
  config.after { Setting.clear_cache }
end
