require 'aizuchi/middleware'

module Aizuchi
  class Railtie < Rails::Railtie
    initializer "aizuchi.insert_middleware" do |app|
      app.config.middleware.use "Aizuchi::Middleware",
        :config => File.expand_path('config/aizuchi.yml', Rails.root)
    end
  end
end

