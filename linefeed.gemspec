# frozen_string_literal: true

require_relative 'lib/linefeed/version'

Gem::Specification.new do |gem|
  gem.name = 'linefeed'
  gem.version = Linefeed::VERSION
  gem.author = 'Joshua Goodall'
  gem.email = 'inopinatus@hey.com'
  gem.summary = 'Yield lines from arbitrarily chunked byte streams'
  gem.description = 'Linefeed turns a push-style byte stream, of any chunk size, into individually yielded lines.'
  gem.homepage = 'https://inopinatus.github.io/linefeed/'
  gem.license = 'MIT'
  gem.required_ruby_version = '>= 3.4'
  gem.files = Dir['lib/**/*.rb', 'README.md', 'CHANGELOG.md', 'LICENSE', 'examples/**/*']
  gem.require_paths = ['lib']
  gem.metadata = {
    'homepage_uri' => 'https://inopinatus.github.io/linefeed/',
    'source_code_uri' => 'https://github.com/inopinatus/linefeed',
    'changelog_uri' => 'https://github.com/inopinatus/linefeed/blob/main/CHANGELOG.md',
    'bug_tracker_uri' => 'https://github.com/inopinatus/linefeed/issues',
    'rubygems_mfa_required' => 'true'
  }
end
