# frozen_string_literal: true

module ActiveadminSettingsCached
  class Model
    include ::ActiveModel::Model

    attr_reader :settings_model, :display

    def initialize(model_name: nil, display: {}, starting_with: nil, **)
      @settings_model = model_name ? model_name.to_s.constantize : ActiveadminSettingsCached.config.model_name
      @display = ActiveadminSettingsCached.config.display.merge(display.stringify_keys)
      @starting_with = starting_with
    end

    def settings
      keys = settings_model.editable_keys
      keys = keys.select { |key| key.start_with?(@starting_with) } if @starting_with
      keys.sort.to_h { |key| [key, settings_model.public_send(key)] }
    end

    def field_options(name, value)
      field = settings_model.get_field(name)
      type = field[:type].to_sym
      kind = display[name] || case type
                              when :boolean then :boolean
                              when :array then :text
                              when :integer, :float then :number
                              else :string
                              end
      options = { as: kind, label: false }
      if kind.to_sym == :boolean
        options[:input_html] = { checked: value == true }
      elsif kind.to_sym == :select
        options[:collection] = field.dig(:options, :option_values) || field[:default]
        options[:selected] = value
      else
        options[:input_html] = { value: value.is_a?(Array) ? value.join("\n") : value }
        options[:input_html][:step] = 'any' if type == :float && kind.to_sym == :number
      end
      options
    end

    def save(name, value)
      raise ArgumentError, "Unknown or read-only setting: #{name}" unless settings.key?(name)

      settings_model.public_send("#{name}=", value)
    end
  end
end
