$: << File.expand_path('../lib', __FILE__)
require 'gruffle/version'

Gem::Specification.new do |s|
  s.name = "gruffle"
  s.version = Gruffle::VERSION
  s.authors = ["Philip Erickson"]
  s.summary = "Graph-based workflows for job processing in Ruby"
  s.homepage = "https://github.com/philipce/gruffle"
  s.files = ["lib/gruffle.rb"]
  s.require_paths = ["lib"]
end
