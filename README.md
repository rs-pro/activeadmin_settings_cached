# ActiveAdmin Settings Cached

An ActiveAdmin 4 settings page for [rails-settings-cached](https://github.com/huacnlee/rails-settings-cached). Requires Ruby 3.2+, Rails 7.2+ and ActiveAdmin 4.0.0.beta20 or later.

## Install

```ruby
gem 'activeadmin_settings_cached'
```

Run `bundle install` and `bin/rails generate settings:install`, then migrate your database. Define fields with the current `rails-settings-cached` API:

```ruby
class Setting < RailsSettings::Base
  field :site_name, default: 'My site'
  field :enabled, type: :boolean, default: true
  field :visits, type: :integer, default: 0
  field :locale, default: 'en', option_values: %w[en de]
  field :api_key, default: '', readonly: true
end
```

Create `app/admin/settings.rb`:

```ruby
ActiveAdmin.register_page 'Settings' do
  active_admin_settings_page display: { locale: :select }
end
```

Only editable fields are shown and accepted on submit. Boolean, numeric, string and array fields select suitable input types automatically. Override an input with `display: { site_name: :text }`. Available options are `model_name` (default `Setting`), `display`, `starting_with` (field-name prefix), `title`, `template` (partial path), `template_object` and `after_save` (callable). For a custom model set `ActiveadminSettingsCached.configure { |config| config.model_name = 'OtherSetting' }` in an initializer.

Use standard ActiveAdmin 4 asset setup in your host application. This gem has no JavaScript or npm package; its form renders on the server. For a complete runnable Rails example using the Tailwind CLI without npm, see [examples/demo](examples/demo/README.md).

## Development

```sh
bundle install
bundle exec rake -f examples/demo/Rakefile assets:build
bundle exec rspec
```

Specs use Capybara/Cuprite with Chrome. Set `CHROME_BIN` if Chrome is installed at a nonstandard path. To test Rails 8 use `RAILS_VERSION='~> 8.0' bundle update rails` followed by the same build and test commands.
