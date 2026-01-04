# frozen_string_literal: true

require_relative 'demo'
require 'linefeed'
require 'digest'

# Only outputs at close
module Demo
  class LineDigest
    include Linefeed

    def initialize(output)
      @output = output
      @line_digest = Digest('SHA256').new

      linefeed do |line|
        @line_digest.update(line)
      end
    end

    def close
      super
      @output << @line_digest.hexdigest
    end
  end
end
