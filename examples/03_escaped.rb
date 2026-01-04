# frozen_string_literal: true

require_relative 'demo'
require 'linefeed'

# Handling the protocol via super
module Demo
  class Escaped
    include Linefeed

    def initialize(output)
      @output = output
    end

    def escape(line)
      line.sub(/^(-|From )/, '- \\1')
    end

    def <<(chunk)
      super do |line|
        @output << escape(line)
      end
    end

    def close
      super do |line|
        @output << "#{escape(line)}\n"
      end
    end
  end
end
