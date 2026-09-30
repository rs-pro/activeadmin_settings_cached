class Setting < RailsSettings::Base
  scope :general do
    field :site_name, default: 'Demo site'
    field :enabled, type: :boolean, default: true
    field :visits, type: :integer, default: 5
    field :rate, type: :float, default: 1.5
    field :welcome, type: :string, default: 'Hello'
    field :tags, type: :array, default: %w[one two]
    field :locale, default: 'en', option_values: %w[en de fr]
    field :secret, default: 'hidden', readonly: true
  end
end
