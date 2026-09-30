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
  s.homepage      = 'https://github.com/rs-pro/activeadmin_settings_cached'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").select do |path|
    path.match?(%r{\A(app|config|lib)/}) || %w[README.md CHANGELOG.md LICENSE.txt].include?(path)
  end
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 3.2'
  s.add_dependency 'activeadmin', '>= 4.0.0.beta20', '< 5'
  s.add_dependency 'rails-settings-cached', '>= 2.9', '< 3'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'cuprite'
  s.add_development_dependency 'importmap-rails'
  s.add_development_dependency 'propshaft'
  s.add_development_dependency 'tailwindcss-rails', '~> 4.4'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sqlite3'
end
