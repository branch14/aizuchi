$:.push File.expand_path('../lib', __FILE__)
require 'aizuchi/version'

Gem::Specification.new do |s|
  s.name        = 'aizuchi'
  s.version     = Aizuchi::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Phil Hofmann']
  s.email       = ['phil@200ok.ch']
  s.homepage    = 'http://github.com/branch14/aizuchi'
  s.summary     = 'Collect instant feedback into a tracker'
  s.description = 'Collect instant feedback into a tracker'

  # s.rubyforge_project = 'aizuchi'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = %w[lib rails]
end
