# frozen_string_literal: true

module ActiveadminSettingsCached
  module Options
    VALID_OPTIONS = %i[
      model_name
      template
      template_object
      display
      title
      after_save
    ].freeze

    def self.options_for(options = {})
      options[:template_object] = ::ActiveadminSettingsCached::Model.new(options) unless options[:template_object]

      {
        template: 'admin/settings/index',
        title: I18n.t('settings.menu.label')
      }.deep_merge(options)
    end
  end
end
