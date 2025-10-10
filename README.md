# Activeadmin Settings Cached

[![Gem Version](https://badge.fury.io/rb/activeadmin_settings_cached.svg)](http://badge.fury.io/rb/activeadmin_settings_cached)
[![CI](https://github.com/rs-pro/activeadmin_settings_cached/workflows/CI/badge.svg)](https://github.com/rs-pro/activeadmin_settings_cached/actions)

Provides a nice UI interface for [rails-settings-cached](https://github.com/huacnlee/rails-settings-cached) gem in [Active Admin](http://activeadmin.info/).

## Version 3.0 - ActiveAdmin 4 & Rails 8 Support! 🎉

**New in 3.0:**
- ✅ Full **ActiveAdmin 4.x** support with Tailwind CSS
- ✅ **Rails 7.0-8.0** compatibility
- ✅ **Ruby 3.2+** support
- ✅ Modern testing with Playwright
- ✅ GitHub Actions CI

**Upgrading from 1.x or 2.x?** See [Upgrade Guide](docs/upgrade-to-v3.md) for step-by-step instructions.

## Compatibility

| activeadmin_settings_cached | ActiveAdmin  | Rails       | Ruby      | rails-settings-cached |
|-----------------------------|--------------|-------------|-----------|----------------------|
| 3.x                         | 2.0+ & 4.x   | 7.0-8.0     | 3.2+      | 2.0+                 |
| 2.x                         | 1.0-2.x      | 5.0-6.x     | 2.5+      | 0.5-2.x              |
| 1.x                         | 1.0          | 4.2-5.x     | 2.0+      | 0.x                  |

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activeadmin_settings_cached'
```

And then execute:

    $ bundle

Create your settings model:

    $ rails g settings:install
    $ bundle exec rake db:migrate

Create your settings page:

    # From generators
    $ rails g active_admin:settings Setting

    # Or manual

``` ruby
# app/admin/setting.rb
ActiveAdmin.register_page 'Setting' do
  title = 'Settings'
  menu label: title

  active_admin_settings_page(
    title: title
  )
end
```

And configure your default values in your Settings model with rails-settings-cached 2.x syntax:

``` ruby
class Setting < RailsSettings::Base
  # Use field declarations (rails-settings-cached 2.x)
  field :my_awesome_settings, default: 'This is my settings', type: :string

  # Group settings with scopes (for UI organization)
  scope :application do
    field :app_name, default: 'My App', type: :string
    field :admin_email, default: 'admin@example.com', type: :string
  end

  scope :features do
    field :enable_notifications, default: true, type: :boolean
  end
end
```

**Note:** rails-settings-cached 2.x uses field-based declarations. See [upgrade guide](docs/upgrade-to-v3.md) if migrating from 0.x.

In your application's admin interface, there will now be a new page with these settings

## ActiveAdmin 4 Setup

If you're using ActiveAdmin 4 with Tailwind CSS, ensure your `tailwind.config.js` includes the gem paths:

```javascript
const { execSync } = require('child_process');
const activeAdminPath = execSync('bundle show activeadmin', {
  encoding: 'utf-8'
}).trim();

module.exports = {
  content: [
    `${activeAdminPath}/app/views/**/*.{arb,erb,html,rb}`,
    './app/admin/**/*.{arb,erb,html,rb}',
    './app/views/**/*.{arb,erb,html,rb}',
    // Include this gem's views
    './vendor/bundle/ruby/*/gems/activeadmin_settings_cached-*/app/**/*.rb',
    './vendor/bundle/ruby/*/gems/activeadmin_settings_cached-*/lib/**/*.rb',
  ],
  // ... rest of config
};
```

Then rebuild your assets:
```bash
npm run build:css  # or your CSS build command
```

For complete ActiveAdmin 4 setup instructions, see [docs/upgrade-to-v3.md](docs/upgrade-to-v3.md#step-3-activeadmin-4-setup-if-upgrading-to-aa4).

## active_admin_settings_page DSL

#### Basic usage

```ruby
ActiveAdmin.register_page 'Settings' do
  menu label: 'Settings', priority: 99
  active_admin_settings_page options
end
```

#### Options
Tool                    | Description
---------------------   | -----------
:model_name					|String, settings model name override (default: uses name from global config.)
:template				|String, custom template rendering (default: 'admin/settings/index')
:template_object				|object passing to view (default: ActiveadminSettingsCached::Model instance)
:display    |Hash, display settings override (default: {})
:title			|String, title value override (default: I18n.t('settings.menu.label'))
:after_save |Proc, callback for action after POST request, (default: nil)


## Localization
You can localize settings keys in local file

``` yml
en:
  settings:
    attributes:
      my_awesome_settings: 'My Awesome Localized Setting'
```
## Model name

By default the name of the mode is `Setting`. If you want to use a different name for the model, you can specify your that in `config/initializers/active_admin_settings_cached.rb`:

``` ruby
ActiveadminSettingsCached.configure do |config|
  config.model_name = 'AdvancedSetting'
end
```

## Display options

If you need define display options for settings fields, eg textarea, url or :timestamp and etc., you can set `display` option in initializer.


``` ruby
ActiveadminSettingsCached.configure do |config|
  config.display = {
    my_awesome_setting_name: :text,
    my_awesome_setting_name_2: :timestamp,
    my_awesome_setting_name_3: :select
  }
end
```

Available options see [here](https://github.com/justinfrench/formtastic#the-available-inputs)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Development

### Running Tests

```bash
# Install dependencies
bundle install
cd spec/internal
npm install
npm run build

# Run all tests
cd ../..
bundle exec rspec

# Run tests with specific Rails version
bundle exec appraisal rails-8.0-active-admin-4.x rspec
```

### Running the Test App

```bash
# Start the development server
bundle exec rackup

# Visit http://localhost:9292/admin
```

## License

MIT License. See LICENSE file for details.
