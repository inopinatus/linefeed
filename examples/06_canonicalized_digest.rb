# frozen_string_literal: true
require_relative 'demo'
require "delegate"

# Easy chaining
module Demo
  class CanonicalizedDigest < DelegateClass(Consumer)
    def initialize(output)
      super(Canonicalize.new(LineDigest.new(output)))
    end
  end
end
