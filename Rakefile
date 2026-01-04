# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rdoc/task'
require 'rake/testtask'
require 'tmpdir'
require 'fileutils'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/**/test_*.rb']
end

directory 'tmp'
file 'tmp/Examples.md' => ['tmp', *FileList['examples/*.rb']] do |f|
  File.open(f.name, 'w') do |out|
    out << <<~HEAD
      # Examples

      Contents of
      {inopinatus/linefeed/examples/}[https://github.com/inopinatus/linefeed/tree/main/examples],
      concatenated here for easy consumption.

    HEAD
    examples = f.prerequisites.sort.grep(/\.rb\z/)
    examples.each do |path|
      out << "## #{File.basename(path)}\n\n```ruby\n"
      out << File.read(path)
      out << "\n```\n\n"
    end
  end
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.include('README.md', 'LICENSE', 'lib/**/*.rb', 'tmp/Examples.md')
  rdoc.main = 'README.md'
  rdoc.rdoc_dir = 'doc'
  rdoc.generator = 'aliki'
  rdoc.title = 'Linefeed RDoc'
  rdoc.options << '--show-hash'
end

desc 'Run the examples'
task :demo do
  ruby '-I lib', 'examples/demo.rb'
end

task default: :test
