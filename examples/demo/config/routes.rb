Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  get '/favicon.ico', to: ->(_env) { [204, {}, []] }
  root to: redirect('/admin/settings')
end
