# Settings demo

From the repository root:

```sh
bundle install
RAILS_ENV=development bundle exec rake -f examples/demo/Rakefile db:migrate
bundle exec rake -f examples/demo/Rakefile assets:build
bundle exec rackup examples/demo/config.ru -p 9292
```

Open http://localhost:9292/admin/settings. The Site Settings page demonstrates a filtered view. This demo does not require Node or an npm package; ActiveAdmin loads its own JavaScript through importmap and the gem renders a server-side form.
