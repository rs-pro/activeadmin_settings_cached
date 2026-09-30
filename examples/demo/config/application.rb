require 'bundler/setup'
require 'rails'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'propshaft'
require 'importmap-rails'
require 'active_admin'
require 'activeadmin_settings_cached'

module SettingsDemo
  class Application < Rails::Application
    config.load_defaults 7.2
    config.secret_key_base = 'demo-only-secret-key-base-at-least-thirty-characters'
    config.eager_load = false
    config.hosts.clear
    config.active_support.cache_format_version = 7.1
    config.root = File.expand_path('..', __dir__)
    config.assets.paths << File.expand_path('../app/assets', __dir__)
    config.logger = ActiveSupport::Logger.new($stdout)
    config.log_level = :warn
  end
end
