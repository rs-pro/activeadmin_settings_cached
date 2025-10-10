# frozen_string_literal: true

require 'rails-settings-cached'
require 'active_admin'

module ActiveadminSettingsCached
  class Engine < Rails::Engine
    engine_name 'activeadmin_settings_cached'

    config.autoload_paths += Dir["#{config.root}/lib"]

    # Include DSL directly - ActiveAdmin 4 may not consistently fire on_load hooks
    initializer 'activeadmin_settings_cached.dsl', before: :load_config_initializers do
      require 'activeadmin_settings_cached/dsl'
      ::ActiveAdmin::DSL.include ::ActiveadminSettingsCached::DSL
    end
  end
end
