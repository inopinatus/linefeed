# frozen_string_literal: true

require "linefeed/version"

module Linefeed
  class Error < StandardError; end
  class StartError < Error; end
  class ClosedError < Error; end
  class MissingHandler < ArgumentError; end

  # Setup linefeed and install default handler.
  def linefeed(&handler)
    raise MissingHandler unless block_given?
    linefeed_start(&handler)
  end

  # Called per binary chunk by push-type sources.
  #
  # Consumers overriding this method should use super { |line| ... }
  def <<(chunk, &handler)
    handler ||= @__linefeed_handler
    raise MissingHandler unless handler
    raise ClosedError if @__linefeed_closed
    linefeed_start unless @__linefeed_started
    buf = @__linefeed_buffer

    if chunk.getbyte(-1) == 10
      if buf.empty?
        chunk.each_line("\n", &handler)
      else
        buf << chunk
        buf.each_line("\n", &handler)
        buf.clear
      end
      return self
    end

    buf << chunk
    return self if chunk.index("\n").nil?

    buf.each_line("\n") do |line|
      if line.getbyte(-1) == 10
        handler.call(line)
      else
        @__linefeed_buffer = line
      end
    end

    self
  end

  # Called at end-of-stream. Note that it is *not* an error to call
  # this without a prior call to #<< or #linefeed.
  #
  # Consumers overriding this method should use super { |line| ... }
  def close(&handler)
    handler ||= @__linefeed_handler
    raise MissingHandler unless handler
    raise ClosedError if @__linefeed_closed
    @__linefeed_closed = true
    return self if !@__linefeed_buffer || @__linefeed_buffer.empty?
    handler.call(@__linefeed_buffer.dup)
    @__linefeed_buffer.clear
    self
  end

  private
  def linefeed_start(&handler)
    raise StartError, "already started" if @__linefeed_started
    raise ClosedError if @__linefeed_closed
    @__linefeed_handler = handler
    @__linefeed_buffer = +"".b
    @__linefeed_closed = false
    @__linefeed_started = true
    self
  end
end
