# frozen_string_literal: true

require_relative 'demo_helper'

if $0 == __FILE__
  example_files = Dir[File.join(__dir__, '[0-9][0-9]_*.rb')]
  example_files.each do |path|
    require_relative File.basename(path)
  end
end

def run
  recipients = Demo.setup_examples
  input = Demo.input_pipe(ARGF)
  maxlen = 8192
  chunk = ''.b

  while input.read(maxlen, chunk) && !chunk.empty?
    recipients.each do |r|
      r << chunk
    end
  end
  recipients.each(&:close)
end

Demo.launcher { run unless $! }
