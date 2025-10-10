# ActiveAdmin 4 Migration Plan for activeadmin_settings_cached

## Overview

This document outlines the complete migration plan for updating `activeadmin_settings_cached` to support:
- **ActiveAdmin 4.0.0.beta16+**
- **Rails 7.x and 8.x**
- **Ruby 3.2+**
- **Propshaft** (Rails 8 default asset pipeline)
- **Tailwind CSS** (ActiveAdmin 4 requirement)
- **Modern testing** with Combustion, Playwright, and GitHub Actions

## Current State

### Gem Structure
- Simple DSL-based gem that adds a settings UI to ActiveAdmin
- No JavaScript or CSS assets (purely server-side)
- Uses dynamic Rails app generation for testing (old approach)
- Targets Rails 5.1+ with ActiveAdmin 1.0+
- Uses legacy testing tools (Poltergeist, Travis CI)

### Core Files
- `lib/activeadmin_settings_cached/dsl.rb` - Main DSL functionality
- `lib/activeadmin_settings_cached/engine.rb` - Rails engine
- `lib/activeadmin_settings_cached/model.rb` - Settings wrapper
- `lib/activeadmin_settings_cached/options.rb` - Configuration options
- Generator for creating settings admin pages

## Migration Strategy

### Phase 1: Dependency Updates

#### 1.1 Gemspec Changes
```ruby
# activeadmin_settings_cached.gemspec
spec.required_ruby_version = '>= 3.2'

spec.add_dependency 'activeadmin', ['>= 2.0', '< 5']
spec.add_dependency 'rails-settings-cached', '>= 2.0.0'

spec.add_development_dependency 'appraisal'
spec.add_development_dependency 'bundler'
spec.add_development_dependency 'capybara', '~> 3.40'
spec.add_development_dependency 'capybara-playwright-driver'
spec.add_development_dependency 'combustion', '~> 1.4'
spec.add_development_dependency 'database_cleaner-active_record'
spec.add_development_dependency 'puma'
spec.add_development_dependency 'rake'
spec.add_development_dependency 'rspec-rails', '~> 6.0'
spec.add_development_dependency 'sqlite3', '~> 2.0'
```

#### 1.2 Appraisals Configuration
```ruby
# Appraisals
appraise 'rails-7.0-activeadmin-4.x' do
  gem 'rails', '~> 7.0.0'
  gem 'activeadmin', '~> 4.0.0.beta16'
  gem 'propshaft'
end

appraise 'rails-7.1-activeadmin-4.x' do
  gem 'rails', '~> 7.1.0'
  gem 'activeadmin', '~> 4.0.0.beta16'
  gem 'propshaft'
end

appraise 'rails-7.2-activeadmin-4.x' do
  gem 'rails', '~> 7.2.0'
  gem 'activeadmin', '~> 4.0.0.beta16'
  gem 'propshaft'
end

appraise 'rails-8.0-activeadmin-4.x' do
  gem 'rails', '~> 8.0.0'
  gem 'activeadmin', '~> 4.0.0.beta16'
  # Propshaft is default in Rails 8
end
```

### Phase 2: Test Infrastructure (Combustion)

#### 2.1 Directory Structure
```
spec/
├── internal/                    # Combustion test app
│   ├── app/
│   │   ├── admin/              # ActiveAdmin resources
│   │   │   └── settings.rb
│   │   ├── assets/
│   │   │   ├── builds/         # Built assets (git-committed)
│   │   │   │   ├── active_admin.css
│   │   │   │   └── active_admin.js
│   │   │   ├── config/
│   │   │   │   └── manifest.js # Propshaft manifest
│   │   │   └── stylesheets/
│   │   │       └── active_admin.css  # Source file for Tailwind
│   │   ├── javascript/
│   │   │   └── active_admin.js
│   │   └── models/
│   │       └── setting.rb      # Test model
│   ├── config/
│   │   ├── database.yml
│   │   ├── environments/
│   │   │   └── test.rb
│   │   ├── initializers/
│   │   │   ├── active_admin.rb
│   │   │   └── activeadmin_settings_cached.rb
│   │   ├── routes.rb
│   │   └── application.rb
│   ├── db/
│   │   ├── schema.rb
│   │   └── migrate/
│   ├── lib/
│   │   └── tasks/
│   │       └── active_admin.rake  # CSS build tasks
│   ├── package.json
│   ├── package-lock.json
│   ├── esbuild.config.js
│   └── tailwind.config.js
├── support/
│   ├── capybara.rb
│   └── wait_helpers.rb
├── system/                      # Feature specs
│   └── settings_spec.rb
├── models/
│   └── setting_spec.rb
└── spec_helper.rb
```

#### 2.2 Key Configuration Files

**config.ru** (for `bundle exec rackup`):
```ruby
require "rubygems"
require "bundler"

Bundler.setup(:default, :development)

require 'combustion'

Combustion.path = 'spec/internal'
Combustion.initialize! :active_record, :action_controller, :action_view do
  config.load_defaults Rails::VERSION::STRING.to_f if Rails::VERSION::MAJOR >= 7
end

# CRITICAL: Load ActiveAdmin AFTER Combustion initializes
require 'importmap-rails' if defined?(Importmap)
require 'active_admin'
require 'activeadmin_settings_cached'

run Combustion::Application
```

**spec/internal/package.json**:
```json
{
  "name": "activeadmin-settings-cached-test",
  "private": true,
  "version": "1.0.0",
  "scripts": {
    "build:js": "node esbuild.config.js",
    "build:css": "bundle exec rake active_admin:build",
    "build": "npm run build:js && npm run build:css",
    "watch:js": "node esbuild.config.js --watch",
    "watch:css": "bundle exec rake active_admin:watch"
  },
  "dependencies": {
    "@activeadmin/activeadmin": "^4.0.0-beta16",
    "@rails/ujs": "^7.1.3"
  },
  "devDependencies": {
    "esbuild": "^0.19.0",
    "tailwindcss": "^3.4.17"
  }
}
```

**spec/internal/tailwind.config.js**:
```javascript
const { execSync } = require('child_process');
const activeAdminPath = execSync('bundle show activeadmin', { encoding: 'utf-8' }).trim();

module.exports = {
  content: [
    `${activeAdminPath}/vendor/javascript/flowbite.js`,
    `${activeAdminPath}/plugin.js`,
    `${activeAdminPath}/app/views/**/*.{arb,erb,html,rb}`,
    './app/admin/**/*.{arb,erb,html,rb}',
    './app/views/**/*.{arb,erb,html,rb}',
    './app/javascript/**/*.js',
    // Include gem files
    '../../lib/**/*.rb',
    '../../app/**/*.{arb,erb,html,rb}'
  ],
  darkMode: 'class',
  plugins: [
    require('@activeadmin/activeadmin/plugin')
  ]
};
```

**spec/internal/esbuild.config.js**:
```javascript
#!/usr/bin/env node
const esbuild = require('esbuild');
const path = require('path');

const config = {
  entryPoints: ['app/javascript/active_admin.js'],
  bundle: true,
  sourcemap: true,
  format: 'esm',
  outdir: 'app/assets/builds',
  publicPath: '/assets',
  loader: { '.js': 'js' },
};

const watchMode = process.argv.includes('--watch');

if (watchMode) {
  esbuild.context(config).then(ctx => {
    ctx.watch();
    console.log('Watching for changes...');
  }).catch(() => process.exit(1));
} else {
  esbuild.build(config).then(() => {
    console.log('Build completed');
  }).catch(() => process.exit(1));
}
```

**spec/internal/lib/tasks/active_admin.rake**:
```ruby
namespace :active_admin do
  desc 'Build Active Admin Tailwind stylesheets'
  task build: :environment do
    command = [
      'npx', 'tailwindcss',
      '-i', Rails.root.join('app/assets/stylesheets/active_admin.css').to_s,
      '-o', Rails.root.join('app/assets/builds/active_admin.css').to_s,
      '-c', Rails.root.join('tailwind.config.js').to_s,
      '-m'
    ]
    system(*command, exception: true)
  end

  desc 'Watch Active Admin Tailwind stylesheets'
  task watch: :environment do
    command = [
      'npx', 'tailwindcss', '--watch',
      '-i', Rails.root.join('app/assets/stylesheets/active_admin.css').to_s,
      '-o', Rails.root.join('app/assets/builds/active_admin.css').to_s,
      '-c', Rails.root.join('tailwind.config.js').to_s,
      '-m'
    ]
    system(*command)
  end
end

Rake::Task['assets:precompile'].enhance(['active_admin:build']) if Rake::Task.task_defined?('assets:precompile')
Rake::Task['test:prepare'].enhance(['active_admin:build']) if Rake::Task.task_defined?('test:prepare')
Rake::Task['spec:prepare'].enhance(['active_admin:build']) if Rake::Task.task_defined?('spec:prepare')
```

### Phase 3: Code Updates

#### 3.1 Engine Updates
```ruby
# lib/activeadmin_settings_cached/engine.rb
require 'rails-settings-cached'
require 'active_admin'

module ActiveadminSettingsCached
  class Engine < Rails::Engine
    engine_name 'activeadmin_settings_cached'

    config.autoload_paths += Dir["#{config.root}/lib"]

    initializer 'activeadmin_settings_cached.dsl', after: :load_config_initializers do
      ActiveSupport.on_load(:active_admin) do
        ::ActiveAdmin::DSL.send(:include, ::ActiveadminSettingsCached::DSL)
      end
    end
  end
end
```

#### 3.2 DSL Updates for Rails 7+
```ruby
# lib/activeadmin_settings_cached/dsl.rb
def active_admin_settings_page(options = {}, &block)
  # ... existing code ...

  page_action :update, method: :post do
    settings_params = params.require(:settings).permit!

    settings_params.each do |field_name, value|
      options[:template_object].save(field_name, value)
    end

    flash[:success] = t('activeadmin_settings_cached.settings.update.success')

    # Rails 7+ compatible redirect
    redirect_back_or_to admin_root_path

    options[:after_save].call if options[:after_save].respond_to?(:call)
  end

  instance_eval(&block) if block_given?
end
```

### Phase 4: GitHub Actions CI

#### 4.1 CI Workflow
```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [master, main]
  pull_request:
    branches: [master, main]

jobs:
  test:
    runs-on: ubuntu-latest
    timeout-minutes: 20

    strategy:
      fail-fast: false
      matrix:
        ruby: ['3.2', '3.3', '3.4']
        gemfile:
          - rails_7.0_active_admin_4.x
          - rails_7.1_active_admin_4.x
          - rails_7.2_active_admin_4.x
          - rails_8.0_active_admin_4.x

    env:
      BUNDLE_GEMFILE: ${{ github.workspace }}/gemfiles/${{ matrix.gemfile }}.gemfile
      RAILS_ENV: test

    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby }}
          bundler-cache: true

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: spec/internal/package-lock.json

      - name: Install npm dependencies
        working-directory: spec/internal
        run: npm ci

      - name: Install Playwright browsers
        run: npx playwright install chromium

      - name: Build JavaScript assets
        working-directory: spec/internal
        run: npm run build:js

      - name: Build CSS assets
        working-directory: spec/internal
        run: npm run build:css

      - name: Setup test database
        run: |
          cd spec/internal
          bundle exec rake db:create db:schema:load RAILS_ENV=test

      - name: Run tests
        run: bundle exec rspec

      - name: Upload coverage
        if: matrix.ruby == '3.4' && matrix.gemfile == 'rails_8.0_active_admin_4.x'
        uses: codecov/codecov-action@v4
        with:
          files: ./coverage/coverage.json

  lint:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.4'
          bundler-cache: true

      - name: Run RuboCop
        run: bundle exec rubocop
```

### Phase 5: Testing Updates

#### 5.1 Modern spec_helper.rb
```ruby
# spec/spec_helper.rb
ENV['RAILS_ENV'] ||= 'test'

require 'combustion'

Combustion.path = 'spec/internal'
Combustion.initialize! :active_record, :action_controller, :action_view do
  config.load_defaults Rails::VERSION::STRING.to_f if Rails::VERSION::MAJOR >= 7
end

require 'rspec/rails'
require 'capybara/rails'

Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
```

#### 5.2 Capybara Configuration
```ruby
# spec/support/capybara.rb
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
```

### Phase 6: Documentation

#### 6.1 README Updates
Add section on ActiveAdmin 4 setup:

```markdown
## ActiveAdmin 4 Compatibility

This gem is compatible with ActiveAdmin 4.x. For ActiveAdmin 4 setup:

### Requirements
- Ruby 3.2+
- Rails 7.0+
- ActiveAdmin 4.0+
- Propshaft (Rails 8 default) or Sprockets

### Installation with ActiveAdmin 4

1. Add to Gemfile:
```ruby
gem 'activeadmin', '~> 4.0.0.beta'
gem 'activeadmin_settings_cached', '~> 2.0'
```

2. Ensure your Tailwind configuration includes the gem paths:
```javascript
// tailwind.config.js
module.exports = {
  content: [
    // ... your paths ...
    './vendor/bundle/ruby/*/gems/activeadmin_settings_cached-*/app/**/*.rb',
  ]
}
```

3. Build your assets:
```bash
npm run build
rails assets:precompile
```
```

## Implementation Checklist

### Immediate Tasks
- [ ] Update gemspec dependencies
- [ ] Create Appraisals configuration
- [ ] Run `bundle exec combust` to generate spec/internal
- [ ] Set up package.json and NPM dependencies
- [ ] Create Tailwind and esbuild configurations
- [ ] Create config.ru for rackup
- [ ] Update engine.rb
- [ ] Update DSL for Rails 7+ compatibility
- [ ] Create GitHub Actions workflow
- [ ] Update spec_helper for Combustion
- [ ] Set up Capybara with Playwright
- [ ] Create test models and admin resources
- [ ] Update existing specs
- [ ] Build and commit initial assets
- [ ] Test with `bundle exec rackup`
- [ ] Test CI pipeline
- [ ] Update README
- [ ] Bump version to 2.0.0

### Testing Verification
```bash
# Local testing
cd spec/internal
npm install
npm run build
cd ../..
bundle exec rackup
# Visit http://localhost:9292/admin

# Run specs
bundle exec rspec

# Test specific Rails versions
bundle exec appraisal rails-8.0-activeadmin-4.x rspec
```

## Migration Benefits

1. **Modern Testing**: Combustion-based setup is faster and more maintainable
2. **CI/CD**: GitHub Actions with matrix testing across Ruby/Rails versions
3. **Asset Pipeline**: Full Propshaft support for Rails 8
4. **Browser Testing**: Playwright for reliable system tests
5. **Future-Proof**: Compatible with ActiveAdmin 4 architecture
6. **Runnable Test App**: Use `rackup` for manual testing and development

## Potential Issues & Solutions

### Issue: Combustion loading order
**Solution**: Load ActiveAdmin AFTER Combustion.initialize! in config.ru

### Issue: Assets not compiling
**Solution**: Ensure npm dependencies are installed and build tasks run before tests

### Issue: Formtastic input not found
**Solution**: Ensure proper loading order in engine initializer

### Issue: Turbo/Hotwire conflicts
**Solution**: Settings page is a simple form, should work with Turbo disabled if needed

## Timeline

- **Phase 1-2**: 2-3 hours (Dependencies + Test Infrastructure)
- **Phase 3**: 1 hour (Code Updates)
- **Phase 4**: 1 hour (CI Setup)
- **Phase 5**: 1-2 hours (Testing Updates)
- **Phase 6**: 30 minutes (Documentation)

**Total Estimated Time**: 5-8 hours

## Next Steps

1. Start with Phase 1 (gemspec and Gemfile updates)
2. Generate Combustion structure with `bundle exec combust`
3. Set up NPM and build configuration
4. Create minimal working test app
5. Update specs one by one
6. Set up CI and verify all matrix combinations pass
