$:.push File.expand_path("../lib", __FILE__)
require "aizuchi/version"

Gem::Specification.new do |s|
  s.name        = "aizuchi"
  s.version     = Aizuchi::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Phil Hofmann"]
  s.email       = ["phil@branch14.org"]
  s.homepage    = "http://branch14.org/aizuchi"
  s.summary     = %q{Collect instant feedback into Redmine}
  s.description = %q{Collect instant feedback into Redmine}

  # s.rubyforge_project = "aizuchi"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib", "rails"]
end
