# frozen_string_literal: true

require_relative 'demo'
require 'linefeed'

# Simplest possible example
module Demo
  class Logger
    include Linefeed

    def initialize(output)
      line_no = 0
      linefeed do |line|
        line_no += 1
        output << format('%<line_no>03d => %<line>s', line_no: line_no, line: line)
      end
    end
  end
end
