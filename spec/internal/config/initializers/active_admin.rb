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

# ActiveAdmin 4 expects importmap-rails in host apps. The Rails 8 test app uses
# esbuild + Tailwind instead, so provide minimal no-op shims so rendering
# doesn't error when calling `javascript_importmap_tags` and `ActiveAdmin.importmap`.

# Stub importmap object that responds to all importmap methods
class ImportmapStub
  def draw(*); end
  def cache_sweeper(*); self; end
  def execute_if_updated(*); end
  # Rails 8 / importmap-rails 2.2.2+ compatibility
  def preloaded_module_packages(*); []; end
end

module ActiveAdmin
  # Provide a stub importmap accessor to satisfy `ActiveAdmin.importmap.draw()` calls
  def self.importmap
    @importmap ||= ImportmapStub.new
  end
end

# Provide a working `javascript_importmap_tags` helper that includes required JS for tests
module ActionView
  module Helpers
    module ImportmapHelperShim
      # Return our stub importmap instance for view helpers
      def importmap
        ActiveAdmin.importmap
      end

      def javascript_importmap_tags(*, **)
        # In tests/dev, include built assets via Rails helpers so Propshaft
        # can resolve digested paths. Use proper Rails asset helpers for Propshaft.
        safe_join([
                    stylesheet_link_tag('active_admin', 'data-turbo-track': 'reload'),
                    javascript_include_tag('active_admin', 'data-turbo-track': 'reload',
                                                           defer: true)
                  ], "\n")
      end
    end
  end
end

ActiveSupport.on_load(:action_view) do
  include ActionView::Helpers::ImportmapHelperShim
end
