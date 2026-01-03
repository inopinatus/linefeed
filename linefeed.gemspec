# frozen_string_literal: true

require_relative "lib/linefeed/version"

Gem::Specification.new do |gem|
  gem.name = "linefeed"
  gem.version = Linefeed::VERSION
  gem.author = "Joshua Goodall"
  gem.email = "inopinatus@hey.com"
  gem.summary = "Yield lines from arbitrarily chunked byte streams"
  gem.description = "Linefeed turns a push-style byte stream, of any chunk size, into individually yielded lines."
  gem.homepage = "https://github.com/inopinatus/linefeed"
  gem.license = "MIT"
  gem.required_ruby_version = ">= 3.4"
  gem.files = Dir["lib/**/*.rb", "README.md", "LICENSE", "examples/**/*", "test/**/*"]
  gem.require_paths = ["lib"]
  gem.metadata = {
    "homepage_uri" => gem.homepage,
    "source_code_uri" => gem.homepage
  }

  gem.add_development_dependency "minitest"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "irb"
end
