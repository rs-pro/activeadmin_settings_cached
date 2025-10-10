# frozen_string_literal: true

# Test Setting model for activeadmin_settings_cached gem
# Uses rails-settings-cached 2.x API with simple field names
class Setting < RailsSettings::Base
  cache_prefix { 'v1' }

  # Define test settings using rails-settings-cached 2.x API
  # Using scope for UI grouping only (not for namespacing)

  scope :application do
    field :app_name, default: 'Test App', type: :string
    field :site_title, default: 'Test Site', type: :string
    field :admin_email, default: 'admin@example.com', type: :string
    field :maintenance_mode, default: false, type: :boolean
  end

  scope :features do
    field :enable_notifications, default: true, type: :boolean
    field :max_upload_size, default: 10, type: :integer
    field :api_timeout, default: 30.5, type: :float
  end

  # Settings for hash type
  field :preferences, default: { theme: 'light', language: 'en' }, type: :hash
end
