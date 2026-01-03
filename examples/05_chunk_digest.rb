# frozen_string_literal: true
require_relative 'demo'
require "digest"

# Not actually using Linefeed, but speaking the same protocol,
# consuming entire chunks.
#
# Should give the same digest as LineDigest.
module Demo
  class ChunkDigest
    def initialize(output)
      @output = output
      @digest = Digest("SHA256").new
    end

    def <<(chunk)
      @digest << chunk
    end

    def close
      @output << @digest.hexdigest
    end
  end
end
