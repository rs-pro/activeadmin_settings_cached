.PHONY: test demo-assets demo

test: demo-assets
	bundle exec rspec

demo-assets:
	bundle exec rake -f examples/demo/Rakefile assets:build

demo: demo-assets
	bundle exec rake -f examples/demo/Rakefile db:migrate
	bundle exec rackup examples/demo/config.ru -p 9292
