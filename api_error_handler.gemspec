# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "api_error_handler/version"

Gem::Specification.new do |spec|
  spec.name          = "api_error_handler"
  spec.version       = ApiErrorHandler::VERSION
  spec.authors       = ["James Stonehill"]
  spec.email         = ["james.stonehill@gmail.com"]
  spec.required_ruby_version = "~> 2.3"

  spec.summary = <<~SUMMARY
    A gem that helps you easily handle exceptions in your Rails API and return
    informative responses to the client.
  SUMMARY

  spec.description = <<~DESCRIPTION
    A gem that helps you easily handle exceptions in your Ruby on Rails API and
    return informative responses to the client by serializing exceptions into JSON
    and other popular API formats and returning a response with a status code that
    makes sense based on the exception.
  DESCRIPTION

  spec.homepage      = "https://github.com/jamesstonehill/api_error_handler"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|rails_.+)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 4.0"
  spec.add_dependency "actionpack", ">= 4.0"
  spec.add_dependency "rack", ">= 1.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec-rails", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.74.0"
end
