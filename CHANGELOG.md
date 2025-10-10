# v3.0.0 (2025-10-10)

**Upgrade Guide:** See [docs/upgrade-to-v3.md](docs/upgrade-to-v3.md) for detailed upgrade instructions.

## Breaking Changes

### Minimum Version Requirements
- **Ruby**: 3.2+ (dropped support for Ruby < 3.2)
- **Rails**: 7.0+ (dropped support for Rails < 7.0)
- **ActiveAdmin**: 2.0+ with full ActiveAdmin 4.x support
- **Asset Pipeline**: Propshaft (Rails 8 default) and Sprockets support

### Rails 7+ Compatibility
- Updated `redirect_to(:back)` to `redirect_back_or_to` for Rails 7+ compatibility
- Updated engine initialization to use modern Rails loading patterns
- Added `ActiveSupport.on_load(:active_admin)` for proper initialization timing

### Testing Infrastructure
- **Removed**: Poltergeist (PhantomJS)
- **Added**: Capybara Playwright Driver for modern browser testing
- **Migrated**: From dynamic Rails app generation to Combustion-based test setup
- **Added**: GitHub Actions CI with matrix testing (Ruby 3.2-3.4, Rails 7.0-8.0)
- Test app now runnable via `bundle exec rackup` for development

## Added

### ActiveAdmin 4 Support
- Full compatibility with ActiveAdmin 4.0.0.beta16+
- Support for Tailwind CSS-based ActiveAdmin themes
- Propshaft asset pipeline integration
- Modern esbuild + Tailwind CSS build pipeline in test app

### Development Dependencies
- `combustion` (~> 1.4) - Modern Rails engine testing
- `capybara-playwright-driver` - Reliable browser automation
- `database_cleaner-active_record` - Database state management
- `puma` - Modern web server
- `rspec-rails` (~> 6.0) - Latest RSpec Rails integration

### Test Infrastructure
- Complete Combustion-based test app in `spec/internal/`
- Package.json with esbuild and Tailwind CSS configuration
- Automated asset building via rake tasks
- GitHub Actions CI with comprehensive matrix testing
- Support for testing multiple Rails versions via Appraisals

### Documentation
- Comprehensive ActiveAdmin 4 migration plan
- Updated README with ActiveAdmin 4 setup instructions
- CI/CD setup documentation

## Changed

### Engine Configuration
- Updated to use proper `ActiveSupport.on_load(:active_admin)` hooks
- Improved initialization order for better compatibility
- Modern Rails engine configuration patterns

### Test Suite
- Migrated from custom Rails template to Combustion
- Updated all specs for modern Capybara matchers
- Improved test reliability with Playwright
- Added proper asset building in CI pipeline

### Dependencies
- Updated `activeadmin` dependency to `['>= 2.0', '< 5']`
- Updated development dependencies to modern versions
- Removed legacy testing dependencies (Poltergeist, Coveralls)
- Added Appraisals for multi-version testing

## Removed

- Dropped Ruby 2.x and 3.0-3.1 support
- Dropped Rails 5.x and 6.x support
- Removed Poltergeist browser testing
- Removed Travis CI configuration
- Removed dynamic Rails app generation in tests
- Removed legacy therubyracer dependency

## Migration Guide

### Upgrading from v2.x

1. **Update Ruby and Rails versions**
   ```ruby
   # Minimum versions required
   ruby '>= 3.2'
   gem 'rails', '>= 7.0'
   gem 'activeadmin', '>= 2.0'
   ```

2. **For ActiveAdmin 4 users**
   - Ensure Tailwind CSS is configured in your application
   - Include gem paths in your `tailwind.config.js`:
     ```javascript
     content: [
       './vendor/bundle/ruby/*/gems/activeadmin_settings_cached-*/app/**/*.rb',
     ]
     ```

3. **Test your settings page**
   - The DSL API remains unchanged
   - Settings display and functionality work the same way
   - Check redirect behavior in your `after_save` callbacks

### ActiveAdmin 2.x vs 4.x

This gem supports both ActiveAdmin 2.x and 4.x:
- **ActiveAdmin 2.x**: Works with existing setup, no changes required
- **ActiveAdmin 4.x**: Requires Tailwind CSS configuration (see README)

## Development

### Running the Test App

```bash
# Install dependencies
bundle install
cd spec/internal
npm install

# Build assets
npm run build

# Start server
cd ../..
bundle exec rackup

# Visit http://localhost:9292/admin
```

### Running Tests

```bash
# All tests
bundle exec rspec

# Specific Rails version
bundle exec appraisal rails-8.0-activeadmin-4.x rspec
```

## Credits

Special thanks to the ActiveAdmin community and gem maintainers whose documentation and examples guided this modernization effort.

---

# v2.3.1 2018-05-22

## Changed

- Remove dry-types dependency

## Fixed
- Breaking change in dry-types: Rename Types::Form to Types::Params (Julien FLAJOLLET)

# v2.2.0 2017-12-22

## Added

- Add `after_save` callback (Alexander Merkulov)

# v2.1.1 2017-08-07

## Fixed

- Fix generator (Alexander Merkulov)
- Fix i18n label content and 'for' attribute (Tom Richards)

# v2.1.0 2016-12-16

## Added

- Allow to use key option to configure `starting_with` option name (Alexander Merkulov)
- German translation (Flyte222)

## Changed

- Default model name is `Setting` instead `Settings`

# v2.0.1 2016-04-25

- Freeze right border for `rails-settings-cached` to `< 0.5.5`

# v2.0.0 2016-04-25

## Added

- Added DSL and multiply settings panels functionality (Alexander Merkulov)

## Changed

- Simplify localization, example

```
en:
  settings:
    attributes:
      my_awesome_settings: 'My Awesome Lolaized Setting'
```

# v1.0.1 2015-10-25

## Fixed

- Fix show settings in admin

# v1.0.0 2015-09-29

## Added

- Allow to configure how display options

# v0.1.0 2015-08-31

## Added

- Added labels to form fields (Derek Kniffin)

# v0.1.0 2015-08-03

## Added

- Show flash message after save settings

## Fixed

- Use proc for display settings name (Dmitry Krakosevich)

# v0.0.5 2015-06-04

## Fixed

- Display settings name if translation is missing (Lunar Farside)

# v0.0.4 2015-05-17

## Added

- Added en local (dixalex)

# v0.0.3 2015-04-30

## Fixed

- Unlock Active Admin dependency

# v0.0.2 2014-11-30

## Fixed

- Fix Active Admin version

# v0.0.1 2014-11-30

First public release
