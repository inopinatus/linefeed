require "bundler/setup"
require 'bundler/gem_tasks'
require "rdoc/task"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "test"
  t.test_files = FileList["test/**/test_*.rb"]
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
  rdoc.main = "README.md"
  rdoc.rdoc_dir = "doc"
  rdoc.generator = 'aliki'
  rdoc.title = 'Linefeed RDoc'
end

desc "Run the examples"
task :demo do
  ruby "examples/demo.rb"
end

task default: :test
