$:.push File.expand_path("../lib", __FILE__)

require "flash_messenger/version"

Gem::Specification.new do |spec|
  spec.name             = 'flash_messenger'
  spec.version          = FlashMessenger::VERSION
  spec.authors          = ['Adam Eberlin']
  spec.email            = ['ae@adameberlin.com']
  spec.homepage         = 'https://github.com/arkbot/flash_messenger'
  spec.summary          = 'Persistent flash messenger.'
  spec.description      = 'Persistent flash messenger.'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'rails', '>= 4.0'
  spec.add_dependency 'activesupport', '>= 4.0'

  spec.add_development_dependency 'factory_girl'
  spec.add_development_dependency 'fivemat'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'pry'
end
