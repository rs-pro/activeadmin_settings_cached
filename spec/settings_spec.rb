# frozen_string_literal: true

RSpec.describe 'ActiveAdmin settings', type: :feature, js: true do
  it 'renders and saves text, boolean, numeric, textarea and select fields in a real browser' do
    visit '/admin/settings'
    expect(page).to have_content('Settings')
    expect(page).to have_field('settings[site_name]', with: 'Demo site')
    expect(page).to have_field('settings[enabled]', checked: true)
    expect(page).to have_field('settings[rate]', with: '1.5')
    expect(page).to have_select('settings[locale]', selected: 'en')
    expect(page).to have_field('settings[tags]', with: "one\ntwo")
    expect(page).not_to have_field('settings[secret]')

    fill_in 'settings[site_name]', with: 'Browser updated'
    fill_in 'settings[visits]', with: '27'
    fill_in 'settings[rate]', with: '2.75'
    fill_in 'settings[welcome]', with: 'Welcome from Chrome'
    fill_in 'settings[tags]', with: "alpha\nbeta"
    uncheck 'settings[enabled]'
    select 'fr', from: 'settings[locale]'
    click_button 'Save Settings'

    expect(page).to have_content('Settings was successfully updated.')
    expect(page).to have_field('settings[site_name]', with: 'Browser updated')
    expect(Setting.site_name).to eq('Browser updated')
    expect(Setting.visits).to eq(27)
    expect(Setting.rate).to eq(2.75)
    expect(Setting.enabled).to eq(false)
    expect(Setting.locale).to eq('fr')
    expect(Setting.welcome).to eq('Welcome from Chrome')
    expect(Setting.tags).to eq(%w[alpha beta])
    expect(Rails.cache.read('settings_saved')).to eq(true)
  end

  it 'limits the secondary page to its configured fields' do
    visit '/admin/site_settings'
    expect(page).to have_field('settings[site_name]')
    expect(page).not_to have_field('settings[visits]')
    fill_in 'settings[site_name]', with: 'Scoped update'
    click_button 'Save Settings'
    expect(page).to have_field('settings[site_name]', with: 'Scoped update')
    expect(Setting.visits).to eq(5)
  end
end

RSpec.describe 'Settings update authorization', type: :request do
  around do |example|
    previous = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = false
    example.run
  ensure
    ActionController::Base.allow_forgery_protection = previous
  end

  it 'ignores unknown and read-only fields in submitted parameters' do
    post '/admin/settings/update', params: { settings: { site_name: 'Allowed', secret: 'Leaked', bogus: 'no' } }
    expect(response).to redirect_to('/admin/settings')
    expect(Setting.site_name).to eq('Allowed')
    expect(Setting.secret).to eq('hidden')
  end

  it 'ignores fields outside the filtered page' do
    post '/admin/site_settings/update', params: { settings: { site_name: 'Allowed', visits: '999' } }
    expect(Setting.site_name).to eq('Allowed')
    expect(Setting.visits).to eq(5)
  end
end
