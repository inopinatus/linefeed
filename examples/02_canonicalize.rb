# frozen_string_literal: true
require_relative 'demo'

# Per-line processing with headers & trailers
module Demo
  class Canonicalize < Consumer
    def initialize(*)
      super
      @output << "---------- START\r\n"
      @output << "Canonicalized: yes\r\n"
      @output << "\r\n"
    end

    def process_line(line)
      canonicalize(line)
    end

    def canonicalize(line)
      line.chomp.sub(/[ \t]+$/, "") + "\r\n"
    end

    def close
      super
      @output << "---------- END\r\n"
      @output.close
    end
  end
end