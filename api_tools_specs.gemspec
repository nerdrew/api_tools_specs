# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'api_tools_specs/version'

Gem::Specification.new do |spec|
  spec.name          = 'api_tools_specs'
  spec.version       = ApiToolsSpecs::VERSION
  spec.authors       = ['Andrew Ryan Lazarus']
  spec.email         = ['nerdrew@gmail.com']
  spec.summary       = %q{Testing tools for api_tools}
  spec.description   = %q{}
  spec.homepage      = ''
  spec.license       = 'MIT'
  spec.post_install_message = <<-EOM
    Rubygems does not support conditional dependencies, hence
    this gem cannot support jruby + mri. This gem requires sqlite
    to work. You must install one of the following:

    JRuby: `gem install activerecord-jdbcsqlite3-adapter`

    MRI: `gem install sqlite3`
  EOM

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '>= 4.0'
  spec.add_runtime_dependency 'activerecord', '>= 4.0'
  spec.add_runtime_dependency "rspec-rails", "~> 3.0"
  spec.add_runtime_dependency "shoulda-matchers", "~> 2.7"
  spec.add_runtime_dependency "rake-hooks", "~> 1.0"

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
