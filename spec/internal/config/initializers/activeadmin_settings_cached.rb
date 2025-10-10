# Configuration for activeadmin_settings_cached gem
ActiveadminSettingsCached.configure do |config|
  # Default model name for settings
  config.model_name = 'Setting'

  # Display settings for form inputs
  # These control how fields are rendered in the admin interface
  config.display = {}
end
