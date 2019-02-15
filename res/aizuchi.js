(function( $ ){

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
      var desc = "## User Feedback\n\n"
          + $('#aizuchi textarea').val() + "\n\n";
      // meta data
      var referer = document.referrer;
      if(referer == "") { referer = "(no referer)"; }
      desc += "## Meta data\n\n```\n"
        + "sent from:   " + document.title + "\n"
        + "URL:         " + document.URL + "\n"
        + "referer:     " + referer + "\n"
        + "user agent:  " + navigator.userAgent + "\n"
        + "screen size: " + screen.width + "x" + screen.height
        + ", color depth: " + screen.colorDepth + "\n";
      desc += "```\n";
      desc += "Installed plugins:\n\n";
      // plugins & mimetypes
      for(var pid=0;pid<navigator.plugins.length;pid++) {
        var plugin = navigator.plugins[pid];
        desc += "* " + plugin.name + "(" + plugin.description + ")\n";
        for(var mid=0;mid<plugin.length;mid++) {
          var mime = plugin[mid];
          desc += "  * " + mime.type + " (" + mime.description + ")\n";
        }
      }
      return desc;
    },

    subject: function() {
      return $('#aizuchi textarea').val().substring(0, 50) + '...';
    },

    markup: function() {
      return "<div id='aizuchi' class='" + this.settings.extra_classes + "'"
        + " onmouseover='Aizuchi.show()'>"
        + "<h1>" + this.settings.text.title + "</h1>"
        + "<form>"
        + "<textarea placeholder='" + this.settings.text.imperative + "'></textarea>"
        + "<div class='buttons'>"
        + "<input type='button' class='save-button' value='" + this.settings.text.submit
        + "' onclick='Aizuchi.send()' />"
        + "<input type='button' class='cancel-button' value='" + this.settings.text.cancel
        + "' onclick='Aizuchi.hide()' />"
        + "</div>"
        + "<form>"
        + "</div>";
    },

    resizeHack: function() {
      $('#aizuchi textarea').height($('#aizuchi').height() - 35);
    },

    show: function() {
      console.log('hide');
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
      console.log('hide');
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
      $('#aizuchi textarea').val('');
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
