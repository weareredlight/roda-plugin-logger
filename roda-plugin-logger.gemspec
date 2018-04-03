# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'roda/plugins/logger/version'

Gem::Specification.new do |spec|
  spec.name          = 'roda-plugin-logger'
  spec.version       = Roda::RodaPlugins::Logger::VERSION
  spec.authors       = ['Tony Goncalves']
  spec.email         = ['tonyfg.pt@gmail.com']

  spec.summary       = 'Write a short summary, because RubyGems requires one.'
  spec.description   = 'Write a longer description or delete this line.'
  spec.homepage      = 'http://example.com'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'roda', '~> 3.6.0'

  spec.add_development_dependency 'bundler', '~> 1.16.1'
  spec.add_development_dependency 'minitest', '~> 5.11.3'
  spec.add_development_dependency 'pry', '~> 0.11.3'
  spec.add_development_dependency 'rake', '~> 12.3.1'
end
