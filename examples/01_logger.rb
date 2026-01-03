# frozen_string_literal: true
require_relative 'demo'

# Simplest possible example
module Demo
  class Logger
    include Linefeed

    def initialize(output)
      line_no = 0
      linefeed do |line|
        output << "%.3d => %s" % [line_no += 1, line]
      end
    end
  end
end
