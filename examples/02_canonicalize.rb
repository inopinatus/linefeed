# frozen_string_literal: true

require_relative 'demo'
require 'linefeed'

# Per-line processing with headers & trailers
module Demo
  class Canonicalize
    include Linefeed

    def initialize(output)
      @output = output
      @output << "---------- START\r\n"
      @output << "Canonicalized: yes\r\n"
      @output << "\r\n"

      linefeed do |line|
        output << process_line(line)
      end
    end

    def process_line(line)
      canonicalize(line)
    end

    def canonicalize(line)
      "#{line.chomp.sub(/[ \t]+$/, '')}\r\n"
    end

    def close
      super
      @output << "---------- END\r\n"
      @output.close
    end
  end
end
