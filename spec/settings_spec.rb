# frozen_string_literal: true

RSpec.describe 'settings', type: :feature, js: true do
  before do
    # Initialize settings using rails-settings-cached 2.x API
    Setting.app_name = 'Test App'
    Setting.site_title = 'Test Site'
    Setting.admin_email = 'admin@example.com'
    Setting.maintenance_mode = false
    Setting.enable_notifications = true
    Setting.max_upload_size = 10
    Setting.api_timeout = 30.5
    Setting.preferences = { theme: 'light', language: 'en' }
  end

  after do
    Setting.clear_cache
  end

  shared_examples_for 'render input with value' do |input_value|
    it 'has input with value' do
      expect(page).to have_selector("input[value='#{input_value}']")
    end
  end

  shared_examples_for 'fill and save settings to db' do
    it 'saves settings to db' do
      fill_in('settings_app_name', with: 'Updated App')
      fill_in('settings_site_title', with: 'Updated Site')
      check('settings_maintenance_mode')

      submit

      expect(Setting.app_name).to eq 'Updated App'
      expect(Setting.site_title).to eq 'Updated Site'
      expect(Setting.maintenance_mode).to eq true
    end
  end

  context 'global config' do
    before do
      ActiveadminSettingsCached.configure do |config|
        config.display = {
          'app_name' => 'string',
          'site_title' => 'string',
          'admin_email' => 'string',
          'maintenance_mode' => 'boolean',
          'enable_notifications' => 'boolean',
          'max_upload_size' => 'number',
          'api_timeout' => 'number'
        }
      end

      add_settings_resource
    end

    context 'settings index' do
      before { visit '/admin/settings' }

      it_behaves_like 'render input with value', 'Test App'
      it_behaves_like 'render input with value', 'Test Site'
      it_behaves_like 'fill and save settings to db'
    end
  end

  context 'with custom template_object' do
    context 'when right object' do
      before do
        display_settings = {
          'app_name' => 'string',
          'site_title' => 'string',
          'maintenance_mode' => 'boolean'
        }

        add_settings_resource(
          template_object: ActiveadminSettingsCached::Model.new(display: display_settings)
        )

        visit '/admin/settings'
      end

      it_behaves_like 'render input with value', 'Test App'
    end

    context 'when wrong object' do
      before do
        add_settings_resource(template_object: nil)

        visit '/admin/settings'
      end

      it_behaves_like 'render input with value', 'Test App'
    end
  end

  describe 'with after_save' do
    context 'when right object' do
      before do
        after_save = ->() {}
        display_settings = {
          'app_name' => 'string',
          'site_title' => 'string',
          'maintenance_mode' => 'boolean'
        }

        expect(after_save).to receive(:call).and_call_original

        add_settings_resource(
          template_object: ActiveadminSettingsCached::Model.new(display: display_settings),
          after_save: after_save
        )

        visit '/admin/settings'

        submit
      end

      it_behaves_like 'render input with value', 'Test App'
    end

    context 'when only open' do
      before do
        after_save = ->() {}

        expect(after_save).not_to receive(:call)

        add_settings_resource(template_object: nil, after_save: after_save)

        visit '/admin/settings'
      end

      it_behaves_like 'render input with value', 'Test App'
    end

    context 'when wrong object' do
      before do
        add_settings_resource(template_object: nil, after_save: 'some')

        visit '/admin/settings'
      end

      it_behaves_like 'render input with value', 'Test App'
    end
  end

  def submit
    click_on('Save Settings')
  end

  def add_settings_resource(options = {})
    options = { model_name: 'Setting', title: 'Settings' }.merge!(options)

    ActiveAdmin.register_page options[:title] do
      menu label: options[:title], priority: 99
      active_admin_settings_page(options)
    end

    Rails.application.reload_routes!
  end
end
