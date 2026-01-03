require "bundler/setup"
require 'bundler/gem_tasks'
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "test"
  t.test_files = FileList["test/**/test_*.rb"]
end

task default: :test

desc "Run the examples"
task :demo do
  ruby "examples/demo.rb"
end
