ActiveAdmin.setup do |config|
  config.site_title = 'Settings Test App'
  config.authentication_method = false
  config.current_user_method = false
  config.batch_actions = true
  config.filter_attributes = %i[encrypted_password password password_confirmation]
  config.localize_format = :long
  # Avoid rendering ActiveAdmin comments (routes are not mounted in test app)
  config.comments = false
end
