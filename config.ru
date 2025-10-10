# frozen_string_literal: true

# This file is used by Rack-based servers to start the application from gem root
# Run with: bundle exec rackup -p 9292

require_relative 'spec/internal/config/environment'

run Rails.application
Rails.application.load_server
