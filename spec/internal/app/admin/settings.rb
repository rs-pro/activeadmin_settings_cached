ActiveAdmin.register_page 'Settings' do
  menu label: 'Settings', priority: 99

  active_admin_settings_page(
    title: 'Application Settings'
  )
end
