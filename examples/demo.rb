# frozen_string_literal: true
require_relative "../lib/linefeed"
require_relative "demo_helper"

if $0 == __FILE__
  example_files = Dir[File.join(__dir__, "[0-9][0-9]_*.rb")].sort
  example_files.each do |path|
    require_relative File.basename(path)
  end
end

def run
  recipients = Demo.setup_examples
  maxlen = 8192
  chunk = "".b

  while $stdin.read(maxlen, chunk)
    recipients.each do |r|
      r << chunk
    end
  end
  recipients.each(&:close)
end

at_exit { run } unless @at_exit_installed; @at_exit_installed = true
