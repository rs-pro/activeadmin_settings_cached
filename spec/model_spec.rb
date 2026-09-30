# frozen_string_literal: true

RSpec.describe ActiveadminSettingsCached::Model do
  subject(:model) { described_class.new(display: { locale: :select }) }

  it 'lists editable fields in name order, excluding read-only fields' do
    expect(model.settings.keys).to eq(%w[enabled locale rate site_name tags visits welcome])
  end

  it 'uses field types and display overrides' do
    expect(model.field_options('enabled', true)).to include(as: :boolean, input_html: { checked: true })
    expect(model.field_options('rate', 1.5)).to include(as: :number, input_html: { value: 1.5, step: 'any' })
    expect(model.field_options('locale', 'en')).to include(as: :select, collection: %w[en de fr])
    expect(model.field_options('tags', %w[one two])).to include(as: :text, input_html: { value: "one\ntwo" })
  end

  it 'filters settings and rejects writes outside the filter' do
    filtered = described_class.new(starting_with: 'site_')
    expect(filtered.settings.keys).to eq(['site_name'])
    expect { filtered.save('secret', 'exposed') }.to raise_error(ArgumentError)
    expect { filtered.save('visits', 99) }.to raise_error(ArgumentError)
    filtered.save('site_name', 'Updated')
    expect(Setting.site_name).to eq('Updated')
  end
end
