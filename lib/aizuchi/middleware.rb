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
        # proxy
        request = Rack::Request.new(env)
        res = post(config['target'], request.POST.to_json,
                   config['user'], config['password'])
        case res
        when Net::HTTPSuccess
          [200, {}, []]
        else
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
            body.insert index, data
            headers['Content-Length'] = body.length.to_s
            response = [body]
          end
        end
        [status, headers, response]
      end
    end

    private

    def default_config
      <<-EOB
---
# Aizuchi -- Instant Feedback
# Aizuchi depends on jQuery >= 1.4.4
# upon changing this file you will need to restart your app
enabled: false
target: https://your.redmine.instance/issues.xml
user: feedback
password: secret
init:
  params:
    project_id: project-handle
    assigned_to_id: 123
    tracker_id: 4
  text:
    imperative: please type your feedback here
    submit: submit
    cancel: cancel
  css:
    hidden:
      top: 150px
      left: -600px
      height: 60px
    visible:
      top: 150px
      left: 0px
      height: 200px
# uncomment the following two lines, if your project
# doesn't use jquery already
# javascripts:
#   - http://code.jquery.com/jquery-1.5.1.min.js
# or this line if you want to ship it yourself
#   - /javascripts/jquery-1.5.1.min.js
# uncomment the following line, in case your project uses prototype
# jquery_noconflict: true
      EOB
    end

    def config
      return @config unless @config.nil?
      path = options[:config]
      raise 'no config path given' unless path
      ::File.open(path, 'w') { |f| f.puts default_config } unless ::File.exist?(path)
      @config = ::File.open(path) { |yf| YAML::load(yf) }
    end

    def post(uri_str, body_str, user=nil , pass=nil)
      url = URI.parse uri_str
      http = Net::HTTP.new url.host, url.port
      http.use_ssl = (url.scheme == 'https')
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new url.path
      request['Content-Type'] = 'application/json'
      request.basic_auth user, pass
      request.body = body_str
      response = http.start { |http| http.request(request) }
      case response
      when Net::HTTPSuccess then response
      else
        response.error!
      end
    end

    def data # DATA doesn't work with Rack
      template = ::File.read(__FILE__).gsub(/.*__END__\n/m, '')
      (config['javascripts'] || []).map do |j|
        "<script type='text/javascript' src='%s'></script>" % j
      end * "\n" + ERB.new(template).result(binding)
    end

  end
end

__END__
<script type="text/javascript">
  (function( $ ){

    <% if config['jquery_noconflict'] %>
    $.noConflict();
    <% end %>

    $(function() { Aizuchi.init(<%= config['init'].to_json %>); });

    Aizuchi = {
      settings: {},
      state: "visible",

      // returns the root url of the application
      root_url: function() {
        var url = window.location.protocol + "//" + window.location.hostname;
        if(window.location.port != "") { url += ":" + window.location.port; }
        return url;
      },

      // build a string, which is posted as the description of the issue
      description: function() {
        var desc = "h1. User Feedback\n\n"
            + $('#aizuchi textarea').val() + "\n\n";
        // meta data
        var referer = document.referrer;
        if(referer == "") { referer = "(no referer)"; }
        desc += "<pre>"
            + "sent from:   " + document.title + "\n"
            + "URL:         " + document.URL + "\n"
            + "referer:     " + referer + "\n"
            + "user agent:  " + navigator.userAgent + "\n"
            + "screen size: " + screen.width + "x" + screen.height
            + ", color depth: " + screen.colorDepth + "\n";
        desc += "</pre>\n";
        desc += "Installed plugins:\n\n";
        // plugins & mimetypes
        for(var pid=0;pid<navigator.plugins.length;pid++) {
            var plugin = navigator.plugins[pid];
            desc += "* " + plugin.name + "(" + plugin.description + ")\n";
            for(var mid=0;mid<plugin.length;mid++) {
                var mime = plugin[mid];
                desc += "** " + mime.type + " (" + mime.description + ")\n";
            }
        }
        return desc;
      },

      subject: function() {
          return $('#aizuchi textarea').val().substring(0, 50) + '...';
      },

      markup: function() {
          return "<div id='aizuchi' class='" + this.settings.extra_classes + "'" +
              + " onmouseover='Aizuchi.show()'>"
              + "<form>"
              + "<textarea>" + this.settings.text.imperative + "</textarea>"
              + "<div class='buttons'>"
              + "<input type='button' value='" + this.settings.text.submit
              + "' onclick='Aizuchi.send()' />"
              + "<input type='button' value='" + this.settings.text.cancel
              + "' onclick='Aizuchi.hide()' />"
              + "</div>"
              + "<form>"
              + "</div>";
      },

      resizeHack: function() {
          $('#aizuchi textarea').height($('#aizuchi').height() - 35);
      },

      show: function() {
          if(this.state == 'visible') { return; }
          $('#aizuchi').addClass('aizuchi-visible')
          //$('#aizuchi').animate(this.settings.css.visible, 150, 'swing', function() {
              //Aizuchi.resizeHack();
              // $('#aizuchi textarea').focus(function() { this.select(); });
              // $('#aizuchi textarea').first().focus();
              Aizuchi.state = 'visible';
          //});
      },

      hide: function() {
          $('#aizuchi').removeClass('aizuchi-visible')
          //$('#aizuchi').animate(this.settings.css.hidden, 150, 'linear', function() {
              //Aizuchi.resizeHack();
              Aizuchi.state = 'hidden';
          //});
          // setTimeout(function() { Aizuchi.state = 'hidden'; }, 500);
      },

      init: function(hash) {
          var dyn = {
            params: {
              target_url:  this.root_url() + "/aizuchi",
              subject:     this.subject,
              description: this.description
            }
          };
          $.extend(true, this.settings, dyn, hash);
          $('body').append(this.markup());
          this.hide();
          // setTimeout(function() { $('#aizuchi').css('display', 'block'); }, 1000);
          setTimeout(function() {
              $('#aizuchi').animate({opacity: 1});
              Aizuchi.state = 'hidden';
          }, 1000);
      },

      responseHandler: function(data, status, request) {},

      send: function() {
          this.sendToRedmine();
          this.hide();
          $('#aizuchi textarea').val(this.settings.text.imperative);
      },

      sendToRedmine: function(hash) {
          if(typeof hash == undefined) { hash = {}; }
          var data = $.extend({}, this.settings.params, hash);
          var url = data.target_url;
          $.post(url, {"issue": data}, this.responseHandler);
      },

      log: function(msg) {
          if(typeof console == undefined) { return; }
          console.log(msg);
      }
    };
  })( jQuery );
</script>
