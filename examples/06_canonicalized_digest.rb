# frozen_string_literal: true
require_relative 'demo'
require 'linefeed'
require "delegate"

# Easy chaining
module Demo
  class CanonicalizedDigest < DelegateClass(Canonicalize)
    def initialize(output)
      super(Canonicalize.new(LineDigest.new(output)))
    end
  end
end
