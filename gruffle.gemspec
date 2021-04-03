$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'gruffle/version'

Gem::Specification.new do |s|
  s.name = 'gruffle'
  s.version = Gruffle::VERSION
  s.authors = ['Philip Erickson']
  s.summary = 'Graph-based workflows for Ruby'
  s.homepage = 'https://github.com/philipce/gruffle'
  s.license = 'MIT'

  s.required_ruby_version = '>= 2.5.1'

  s.files = ['lib/gruffle.rb']
  s.require_paths = ['lib']
end
