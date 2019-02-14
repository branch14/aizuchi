require 'aizuchi/middleware'

module Aizuchi
  case Rails.version.to_i
  when 2
    path = File.expand_path('config/aizuchi.yml', RAILS_ROOT)
    Rails.configuration.middleware.use Aizuchi::Middleware, config: path

  when 3
    class Railtie < Rails::Railtie
      initializer 'aizuchi.insert_middleware' do |app|
        path = File.expand_path('config/aizuchi.yml', Rails.root)
        app.config.middleware.use 'Aizuchi::Middleware', config: path
      end
    end

  # TODO 4

  when 5
    class Railtie < Rails::Railtie
      initializer 'aizuchi.insert_middleware' do |app|
        path = File.expand_path('config/aizuchi.yml', Rails.root)
        app.middleware.use Aizuchi::Middleware, config: path
      end
    end

  else
    raise "Unknown Rails version #{rails_version}"
  end
end
