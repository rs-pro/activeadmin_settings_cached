# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activeadmin_settings_cached/version'

Gem::Specification.new do |s|
  s.name          = 'activeadmin_settings_cached'
  s.version       = ActiveadminSettingsCached::VERSION
  s.authors       = ['Semyon Pupkov']
  s.email         = ['mail@semyonpupkov.com']
  s.summary       = 'UI interface for rails-settings-cached in active admin'
  s.description   = 'UI interface for rails-settings-cached in active admin'
  s.homepage      = 'https://github.com/artofhuman/activeadmin_settings_cached'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 3.2'

  s.add_dependency 'activeadmin', '~> 4.0.0.beta16'
  s.add_dependency 'rails-settings-cached', '>= 2.0.0'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'capybara', '~> 3.40'
  s.add_development_dependency 'capybara-playwright-driver'
  s.add_development_dependency 'combustion', '~> 1.4'
  s.add_development_dependency 'database_cleaner-active_record'
  s.add_development_dependency 'puma'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec-rails', '~> 6.0'
  s.add_development_dependency 'sqlite3', '~> 2.0'
end
