# frozen_string_literal: true
require_relative 'demo'
require 'linefeed'

# Intentionally fails to setup the feed and suffers for it.
# Don't do this.
module Demo
  class Null
    include Linefeed

    def initialize(output)
      @output = output
      @count = 0
    end

    def <<(*)
      super
    rescue ArgumentError
      @count += 1
    end

    def close
      super
    rescue ArgumentError
      @output << "rescued #{@count += 1} time(s)"
    end
  end
end
