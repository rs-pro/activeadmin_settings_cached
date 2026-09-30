ActiveAdmin.register_page 'Settings' do
  menu priority: 1
  active_admin_settings_page display: { welcome: :text, locale: :select },
                             after_save: -> { Rails.cache.write('settings_saved', true) }
end
