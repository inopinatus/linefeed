# frozen_string_literal: true
require_relative 'demo'

# Handling the protocol via super
module Demo
  class Escaped < Consumer
    def escape(line)
      line.sub(/^(-|From )/, "- \\1")
    end

    def <<(chunk)
      super(chunk) do |line|
        @output << escape(line)
      end
    end

    def close
      super do |line|
        @output << escape(line) + "\n"
      end
    end
  end
end