# This file is used by Rack-based servers to start the application.
# Run with: bundle exec rackup -p 9292

require_relative 'config/environment'

run Rails.application
Rails.application.load_server
