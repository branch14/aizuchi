# (c) 2011,2019 Phil Hofmann <phil@200ok.ch>
#
# after install see config/aizuchi.yml for more information

require 'net/https'

module Aizuchi
  # The Middleware
  class Middleware < Struct.new(:app, :options)
    def call(env)
      return app.call(env) unless config['enabled']
      if env['REQUEST_METHOD'] == 'POST' &&
         env['PATH_INFO'] =~ %r{^\/aizuchi} &&
         !config['exclude'].include?(env['PATH_INFO'])
        # run handler
        title = "Feedback on #{env['PATH_INFO']}"
        text = Rack::Request.new(env).POST.to_yaml
        begin
          eval(config['handler'] + '(title, text)')
          [200, {}, []]
        rescue
          [500, {}, []]
        end
      else
        # inject
        status, headers, response = app.call(env)
        if headers['Content-Type'] =~ %r{text\/html|application\/xhtml\+xml}
          body = ''
          response.each { |part| body << part }
          index = body.rindex '</body>'
          if index
            body.insert index, injectable
            headers['Content-Length'] = body.length.to_s
            response = [body]
          end
        end
        [status, headers, response]
      end
    end

    private

    def default_config
      read(%w(.. .. res aizuchi.yml))
    end

    def config
      return @config unless @config.nil?
      path = options[:config]
      raise 'no config path given' unless path
      ::File.open(path, 'w') { |f| f.puts default_config } unless ::File.exist?(path)
      @config = ::File.open(path) { |yf| YAML::load(yf) }
    end

    def injectable
      code = read(%w[.. .. res aizuchi.js])
      template = read(%w[.. .. res aizuchi.js.erb])
      ((config['javascripts'] || []).map do |j|
         "<script type='text/javascript' src='%s'></script>" % j
       end * "\n") +
        '<script>' + code + "\n" + ERB.new(template).result(binding) + '</script>'
    end

    def read(*path)
      ::File.read(::File.expand_path(::File.join(['..'] + path.flatten), __FILE__))
    end
  end
end
