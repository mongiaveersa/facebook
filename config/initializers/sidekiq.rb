require 'sidekiq'
require 'sidekiq/web'

Sidekiq.configure_client do |config|
  config.redis = { :size => 5 }
end

Sidekiq.configure_server do |config|
  config.redis = { :size => 25 }
end

Sidekiq::Web.set :sessions, false