require 'aizuchi/middleware'

module Aizuchi
  
  case Rails.version.to_i
  when 2
    Rails.configuration.middleware.use Aizuchi::Middleware,
      :config => File.expand_path('config/aizuchi.yml', RAILS_ROOT)

  when 3
    class Railtie < Rails::Railtie
      initializer "aizuchi.insert_middleware" do |app|
        app.config.middleware.use "Aizuchi::Middleware",
        :config => File.expand_path('config/aizuchi.yml', Rails.root)
      end
    end

  else
    raise "Unknown Rails version #{rails_version}"
  end

end

