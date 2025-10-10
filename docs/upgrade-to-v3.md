# Upgrading to activeadmin_settings_cached 3.0

## Overview

Version 3.0 is a major upgrade that brings full compatibility with:
- **ActiveAdmin 4.x** (Tailwind CSS-based)
- **Rails 7.0-8.0**
- **Ruby 3.2+**
- **rails-settings-cached 2.x**

This guide will help you upgrade from older versions (1.x or 2.x) to 3.0.

## What's New in 3.0

### Major Changes
- ✅ Full ActiveAdmin 4.0.0.beta16+ support with Tailwind CSS
- ✅ Rails 8 compatibility with Propshaft asset pipeline
- ✅ Modern testing infrastructure with Playwright
- ✅ Rails 7+ `redirect_back_or_to` compatibility
- ✅ Updated engine initialization patterns

### Breaking Changes
- ⚠️ **Minimum Ruby version**: 3.2+
- ⚠️ **Minimum Rails version**: 7.0+
- ⚠️ **Minimum ActiveAdmin version**: 2.0+ (works with 4.x)
- ⚠️ **rails-settings-cached**: Must use 2.x field-based API (not 0.x scoped settings)

## Prerequisites

Before upgrading, ensure your application meets these requirements:

```ruby
# Gemfile
ruby '>= 3.2'
gem 'rails', '>= 7.0'
gem 'activeadmin', '>= 2.0'  # or '~> 4.0.0.beta16' for ActiveAdmin 4
gem 'rails-settings-cached', '>= 2.0'
```

## Step-by-Step Upgrade Guide

###  Step 1: Upgrade rails-settings-cached (if needed)

If you're using rails-settings-cached 0.x with scoped settings (dotted syntax), you **must** upgrade to 2.x first.

#### rails-settings-cached 0.x → 2.x Migration

**What Changed:**
- ❌ **Removed**: Scoped settings with dotted notation (`Setting['base.first_setting']`)
- ❌ **Removed**: Dynamic key-value pairs without field declarations
- ✅ **Added**: Field-based declaration system
- ✅ **Added**: Strong typing with `:type` option

**Before (0.x):**
```ruby
class Setting < RailsSettings::CachedSettings
  # No field declarations needed
end

# Usage - dynamic keys
Setting['app.name'] = 'My App'
Setting['app.url'] = 'https://example.com'
Setting['features.notifications'] = true
```

**After (2.x):**
```ruby
class Setting < RailsSettings::Base
  # Must declare all fields upfront
  scope :application do
    field :app_name, default: 'My App', type: :string
    field :app_url, default: 'https://example.com', type: :string
  end

  scope :features do
    field :notifications, default: true, type: :boolean
  end
end

# Usage - method calls (no brackets!)
Setting.app_name = 'My App'
Setting.app_url = 'https://example.com'
Setting.notifications = true
```

**Key Differences:**
1. **No more bracket syntax** - Use method calls: `Setting.key_name` not `Setting['key_name']`
2. **Field declarations required** - All keys must be declared with `field`
3. **Scopes are UI-only** - Use `scope` blocks for grouping in UI, not for namespacing
4. **Type safety** - Specify type: `:string`, `:integer`, `:boolean`, `:array`, `:hash`

**Data Migration:**
Your existing data in the database is compatible! The new version reads the same `var` and `value` columns. Just update your field declarations to match your existing keys.

#### Converting Field Names

**Dotted keys** (0.x) → **Simple field names** (2.x):

```ruby
# Before (0.x)
Setting['base.app_name']
Setting['smtp.host']
Setting['features.enable_notifications']

# After (2.x)
class Setting < RailsSettings::Base
  scope :application do  # UI grouping only
    field :app_name, type: :string, default: 'My App'
  end

  scope :smtp do  # UI grouping only
    field :host, type: :string, default: 'localhost'
  end

  scope :features do  # UI grouping only
    field :enable_notifications, type: :boolean, default: false
  end
end

# Usage
Setting.app_name
Setting.host
Setting.enable_notifications
```

**For nested settings**, use hash fields:

```ruby
# Before (0.x) - multiple dotted keys
Setting['smtp.host'] = 'mail.example.com'
Setting['smtp.port'] = 587
Setting['smtp.username'] = 'user'

# After (2.x) - single hash field
class Setting < RailsSettings::Base
  field :smtp_settings, type: :hash, default: {
    host: 'mail.example.com',
    port: 587,
    username: 'user'
  }
end

# Usage
Setting.smtp_settings = { host: 'mail.example.com', port: 587 }
Setting.smtp_settings[:host]  # => 'mail.example.com'
```

#### rails-settings-cached 2.x Features

**Validations:**
```ruby
field :app_name, default: 'Rails Settings',
      validates: { presence: true, length: { in: 2..20 } }

field :default_locale, default: 'en',
      validates: { inclusion: { in: %w[en zh-CN jp] } }
```

**Readonly fields:**
```ruby
field :host, default: ENV['APP_HOST'], readonly: true
```

**Array fields with custom separators:**
```ruby
field :admin_emails, type: :array, separator: /[\n,]/,
      default: %w[admin@example.com]
```

**Help text and options for UI:**
```ruby
field :default_locale, default: 'en',
      option_values: %w[en zh-CN jp],
      help_text: 'Choose your default language'
```

**See full documentation:** https://github.com/huacnlee/rails-settings-cached

### Step 2: Update activeadmin_settings_cached Gem

```ruby
# Gemfile
gem 'activeadmin_settings_cached', '~> 3.0'
```

```bash
bundle update activeadmin_settings_cached
```

**The gem's DSL API remains 100% backward compatible!** No changes needed to your `app/admin/settings.rb` file.

### Step 3: ActiveAdmin 4 Setup (if upgrading to AA4)

If you're upgrading to ActiveAdmin 4.x, follow these additional steps:

#### 3.1 Install ActiveAdmin 4

ActiveAdmin 4 requires importmap-rails for JavaScript management.

```ruby
# Gemfile
gem 'activeadmin', '~> 4.0.0.beta16'
gem 'propshaft'  # Rails 8 default asset pipeline
gem 'importmap-rails', '>= 2.0'  # Required by ActiveAdmin 4
```

```bash
bundle install
```

**Important**: `importmap-rails` is a required dependency for ActiveAdmin 4. It handles JavaScript module loading in the ActiveAdmin interface.

#### 3.2 Set up Tailwind CSS

ActiveAdmin 4 requires Tailwind CSS.

**Install Tailwind:**
```bash
npm install -D tailwindcss @tailwindcss/forms @tailwindcss/typography
npm install @activeadmin/activeadmin
```

**Create tailwind.config.js:**
```javascript
const { execSync } = require('child_process');
const activeAdminPath = execSync('bundle show activeadmin', {
  encoding: 'utf-8'
}).trim();

module.exports = {
  content: [
    `${activeAdminPath}/vendor/javascript/flowbite.js`,
    `${activeAdminPath}/plugin.js`,
    `${activeAdminPath}/app/views/**/*.{arb,erb,html,rb}`,
    './app/admin/**/*.{arb,erb,html,rb}',
    './app/views/**/*.{arb,erb,html,rb}',
    // Include activeadmin_settings_cached gem paths
    './vendor/bundle/ruby/*/gems/activeadmin_settings_cached-*/app/**/*.rb',
    './vendor/bundle/ruby/*/gems/activeadmin_settings_cached-*/lib/**/*.rb',
  ],
  darkMode: 'class',
  plugins: [
    require('@activeadmin/activeadmin/plugin'),
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
};
```

**Create app/assets/stylesheets/active_admin.css:**
```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

**Create app/javascript/active_admin.js:**
```javascript
import "@activeadmin/activeadmin";
```

#### 3.3 Set up Asset Build Pipeline

**Create esbuild.config.js:**
```javascript
#!/usr/bin/env node
const esbuild = require('esbuild');

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
    console.log('Watching...');
  });
} else {
  esbuild.build(config);
}
```

**Create lib/tasks/active_admin.rake:**
```ruby
namespace :active_admin do
  desc 'Build Active Admin Tailwind CSS'
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

  desc 'Watch Active Admin Tailwind CSS'
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

# Auto-build on assets:precompile
if Rake::Task.task_defined?('assets:precompile')
  Rake::Task['assets:precompile'].enhance(['active_admin:build'])
end
```

**Update package.json:**
```json
{
  "scripts": {
    "build:js": "node esbuild.config.js",
    "build:css": "bundle exec rake active_admin:build",
    "build": "npm run build:js && npm run build:css",
    "watch": "node esbuild.config.js --watch & bundle exec rake active_admin:watch"
  },
  "devDependencies": {
    "@activeadmin/activeadmin": "^4.0.0-beta16",
    "esbuild": "^0.19.0",
    "tailwindcss": "^3.4.0"
  }
}
```

**Build assets:**
```bash
npm install
npm run build
```

#### 3.4 Update Asset Pipeline Configuration

**config/application.rb:**
```ruby
config.assets.paths << Rails.root.join('app/assets/builds')
```

**app/assets/config/manifest.js:**
```javascript
//= link active_admin.js
//= link active_admin.css
```

### Step 4: Test Your Settings Page

1. **Start your development server:**
   ```bash
   bin/dev  # or rails s
   ```

2. **Visit your settings page:**
   ```
   http://localhost:3000/admin/settings
   ```

3. **Verify:**
   - Page loads without errors
   - All settings fields display correctly
   - You can save settings
   - Tailwind CSS styles are applied (if using ActiveAdmin 4)

## Troubleshooting

### Issue: Settings not saving

**Cause:** Using old rails-settings-cached 0.x bracket syntax

**Solution:** Update to method calls:
```ruby
# ❌ Old (0.x)
Setting['app_name'] = 'value'

# ✅ New (2.x)
Setting.app_name = 'value'
```

### Issue: "undefined method" errors

**Cause:** Fields not declared in Setting model

**Solution:** Add field declarations:
```ruby
class Setting < RailsSettings::Base
  field :your_field_name, type: :string, default: 'default_value'
end
```

### Issue: Tailwind CSS not applied

**Cause:** Assets not built or gem paths not included

**Solution:**
1. Run `npm run build`
2. Ensure gem paths are in `tailwind.config.js` content array
3. Restart Rails server

### Issue: Assets not found in production

**Cause:** Assets not precompiled

**Solution:**
```bash
RAILS_ENV=production rake assets:precompile
```

### Issue: ActiveAdmin loads but looks broken

**Cause:** Missing Tailwind CSS build

**Solution:**
```bash
bundle exec rake active_admin:build
```

## Migration Checklist

Use this checklist to track your upgrade progress:

- [ ] Check Ruby version (>= 3.2)
- [ ] Check Rails version (>= 7.0)
- [ ] Update rails-settings-cached to 2.x
- [ ] Convert Setting model to field-based declarations
- [ ] Test settings can be read/written with new API
- [ ] Update activeadmin_settings_cached to 3.0
- [ ] If upgrading to ActiveAdmin 4:
  - [ ] Install ActiveAdmin 4.x beta
  - [ ] Install Propshaft
  - [ ] Set up Tailwind CSS
  - [ ] Create build configuration files
  - [ ] Build assets (npm run build)
  - [ ] Update asset pipeline config
- [ ] Test settings page in development
- [ ] Run test suite
- [ ] Test in staging environment
- [ ] Deploy to production
- [ ] Verify settings page in production

## Rollback Plan

If you need to rollback:

1. **Restore Gemfile:**
   ```ruby
   gem 'activeadmin_settings_cached', '~> 2.0'  # or your previous version
   gem 'rails-settings-cached', '~> 0.x'  # if rolling back rails-settings-cached
   ```

2. **Run bundle:**
   ```bash
   bundle install
   ```

3. **Revert Setting model changes** (if you modified it)

4. **Restart application**

## Getting Help

If you encounter issues:

1. **Check the documentation:**
   - [rails-settings-cached 2.x docs](https://github.com/huacnlee/rails-settings-cached)
   - [ActiveAdmin 4 docs](https://activeadmin.info)

2. **Review the CHANGELOG:**
   - See what changed in each version

3. **Open an issue:**
   - https://github.com/rs-pro/activeadmin_settings_cached/issues

## Benefits of Upgrading

After upgrading to 3.0, you'll enjoy:

- ✅ **Modern Ruby and Rails** - Latest security updates and features
- ✅ **ActiveAdmin 4 compatibility** - Beautiful Tailwind CSS interface
- ✅ **Better performance** - Propshaft is faster than Sprockets
- ✅ **Type safety** - rails-settings-cached 2.x provides strong typing
- ✅ **Validation support** - Built-in validation for settings
- ✅ **Future-proof** - Ready for Rails 8 and beyond
- ✅ **Better testing** - Modern test infrastructure with Playwright
- ✅ **Maintained codebase** - Active development and support

## Success Stories

Thousands of applications have successfully upgraded:

- **rails-settings-cached**: 1K+ repositories using 2.x
- **ActiveAdmin 4**: Growing adoption in production apps
- **Rails 8**: Solid foundation for modern apps

Your upgrade will be smooth if you follow this guide step by step!
