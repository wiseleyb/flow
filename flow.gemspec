$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "flow/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "flow"
  s.version     = Flow::VERSION
  s.authors     = ["Ben Wiseley"]
  s.email       = ["wiseleyb@gmail.com"]
  s.homepage    = "https://github.com/wiseleyb"
  s.summary     = "Simple dev flow helper"
  s.description = "A utility for simplifying the hoops developers need to jump through"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.1.13"
  s.add_dependency 'pivotal-tracker', '~> 0.5.13'
end
