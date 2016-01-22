# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'codes/version'

Gem::Specification.new do |spec|
  spec.name          = 'codes'
  spec.version       = Codes::VERSION
  spec.authors       = ['Felix Krause']
  spec.email         = ['codes@krausefx.com']
  spec.summary       = 'Create promo codes for iOS Apps using the command line'
  spec.description   = 'Create promo codes for iOS Apps using the command line'
  spec.homepage      = 'https://fastlane.tools'

  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir['lib/**/*'] + %w( bin/codes README.md LICENSE )

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'fastlane_core', '>= 0.16.0', '< 1.0.0' # all shared code and dependencies

  # Frontend Scripting
  spec.add_dependency 'phantomjs', '~> 1.9.8' # dependency for poltergeist
  spec.add_dependency 'capybara', '~> 2.4.3' # for controlling iTC
  spec.add_dependency 'poltergeist', '~> 1.5.1' # headless Javascript browser for controlling iTC

  # Development only
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'yard', '~> 0.8.7.4'
  spec.add_development_dependency 'webmock', '~> 1.19.0'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'fastlane'
  spec.add_development_dependency 'rubocop', '~> 0.35.1'
end
