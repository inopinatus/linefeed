# frozen_string_literal: true

module Linefeed
  # Base error for linefeed-specific failures.
  class Error < StandardError; end

  # Raised when linefeed is started more than once.
  class StartError < Error; end

  # Raised when operations are attempted after close.
  class ClosedError < Error
    def initialize(message = "already closed")
      super
    end
  end

  # Raised when no handler is provided for line processing. Subclass of
  # {ArgumentError}[https://docs.ruby-lang.org/en/master/ArgumentError.html]
  class MissingHandler < ArgumentError; end
end
