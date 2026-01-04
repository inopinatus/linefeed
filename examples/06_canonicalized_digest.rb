# frozen_string_literal: true

require_relative '02_canonicalize'
require_relative '04_line_digest'
require 'delegate'

# Easy chaining
module Demo
  class CanonicalizedDigest < DelegateClass(Canonicalize)
    def initialize(output)
      super(Canonicalize.new(LineDigest.new(output)))
    end
  end
end
