# Use the test app's Gemfile only if BUNDLE_GEMFILE is not already set
# This allows Appraisals to work while still supporting standalone usage
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
