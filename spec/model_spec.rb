# frozen_string_literal: true

RSpec.describe ActiveadminSettingsCached::Model do
  include ActiveModel::Lint::Tests

  ActiveModel::Lint::Tests.public_instance_methods.map(&:to_s).grep(/^test/).each do |m|
    example m.gsub('_', ' ') do
      send m
    end
  end

  # Setup test data using modern rails-settings-cached 2.0+ API
  before(:all) do
    # Set values directly using the new API
    Setting.app_name = 'Test App'
    Setting.maintenance_mode = false
    Setting.max_upload_size = 10
  end

  after(:all) do
    # Reset to defaults
    Setting.app_name = Setting.get_field(:app_name)[:default]
    Setting.maintenance_mode = Setting.get_field(:maintenance_mode)[:default]
    Setting.max_upload_size = Setting.get_field(:max_upload_size)[:default]
  end

  let(:all_options) do
    {
      model_name: 'Setting',
      starting_with: nil,
      key: nil,
      display: {}
    }
  end

  let(:no_options) do
    {}
  end

  describe '#attributes' do
    before do
      ActiveadminSettingsCached.config.display = {}
    end

    it 'set options' do
      object = described_class.new(all_options)
      expect(object.attributes[:model_name]).to eq(Setting)
      expect(object.attributes[:display]).to eq({})
    end

    it 'set default options' do
      object = described_class.new(no_options)
      expect(object.attributes[:model_name]).to eq(Setting)
      expect(object.attributes[:display]).to be_a(Hash)
    end
  end

  describe '#field_options' do
    it 'with string field' do
      object = described_class.new(all_options.merge({ display: { 'app_name' => :string } }))
      options = object.field_options('app_name', 'Test App')
      expect(options[:as]).to eq(:string)
      expect(options[:input_html][:value]).to eq('Test App')
      expect(options[:label]).to be(false)
    end

    it 'with boolean field' do
      object = described_class.new(all_options.merge({ display: { 'maintenance_mode' => :boolean } }))
      options = object.field_options('maintenance_mode', false)
      expect(options[:as]).to eq(:boolean)
      expect(options[:input_html][:checked]).to be(false)
      expect(options[:checked_value]).to eq('true')
      expect(options[:unchecked_value]).to eq('false')
    end

    it 'with integer field' do
      object = described_class.new(all_options.merge({ display: { 'max_upload_size' => :number } }))
      options = object.field_options('max_upload_size', 10)
      expect(options[:as]).to eq(:number)
      expect(options[:input_html][:value]).to eq(10)
    end

    it 'with array field' do
      # Test with the preferences hash field
      object = described_class.new(all_options.merge({ display: { 'preferences' => :hash } }))
      options = object.field_options('preferences', { theme: 'light' })
      expect(options[:as]).to eq(:hash)
      expect(options[:input_html][:value]).to eq({ theme: 'light' })
    end
  end

  describe '#settings' do
    it 'returns all settings as hash' do
      object = described_class.new(all_options)
      settings = object.settings
      expect(settings).to be_a(Hash)
      expect(settings['app_name']).to eq('Test App')
      expect(settings['maintenance_mode']).to be(false)
      expect(settings['max_upload_size']).to eq(10)
    end
  end

  describe '#save' do
    it 'saves settings' do
      object = described_class.new(all_options)
      object.save('app_name', 'Updated Name')
      expect(Setting.app_name).to eq('Updated Name')

      # Reset
      Setting.app_name = 'Test App'
    end
  end

  describe '#display' do
    it 'returns display options' do
      object = described_class.new(all_options.merge({ display: { 'app_name' => :string } }))
      expect(object.display).to eq({ 'app_name' => :string })
    end
  end

  describe '#persisted?' do
    it 'returns false' do
      object = described_class.new(all_options)
      expect(object.persisted?).to be(false)
    end
  end

  def model
    subject
  end
end
