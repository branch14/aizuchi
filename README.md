Aizuchi - Instant Feedback Tool
===============================

[Aizuchi](http://en.wikipedia.org/wiki/Aizuchi) is a
[Rack](http://rack.rubyforge.org/) based middleware which
automatically integrates with [Rails](http://rubyonrails.org/) to
display a form to collect feedback from your clients. Aizuchi
therefore creates issues via [Redmine's](http://www.redmine.org/) REST
API. 

Install in Rails
----------------

Put the following in your Gemfile and run `bundle install` or let
[Guard](https://github.com/guard/guard-bundler) kick in.

    gem 'aizuchi'

Using Aizuchi outside of Rails
------------------------------

    require 'aizuchi/middleware'
    use Aizuchi::Middleware, :config => 'path/to/config/aizuchi.yml'

Configure
---------

Aizuchi will create a sample config file in `config/aizuchi.yml`.
Aizuchi is disabled by default, but you'll have to edit this config file
anyways.

Patches and the like
--------------------

If you run into bugs, have suggestions, patches or want to use Aizuchi
with something else than Rails or Redmine feel free to drop me a line.

License
-------

Aizuchi is release under MIT License, see LICENSE.