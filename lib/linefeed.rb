# frozen_string_literal: true

require "linefeed/version"

module Linefeed
  class Error < StandardError; end

  def linefeed(&default_proc)
    raise ArgumentError, "linefeed already called" if @__linefeed_called
    @__linefeed_default = default_proc
    @__linefeed_buffer = +"".b
    @__linefeed_closed = false
    @__linefeed_called = true
    self
  end

  # Called by push-type source to write to us.
  def <<(chunk, &per_line)
    per_line ||= @__linefeed_default
    raise Error, "already closed" if @__linefeed_closed
    raise ArgumentError, "no line handler" unless per_line

    @__linefeed_called = true
    @__linefeed_buffer ||= +"".b
    @__linefeed_buffer << chunk

    start = 0
    while (eol = @__linefeed_buffer.index("\n", start))
      per_line.call(@__linefeed_buffer.slice(start..eol)) # includes the "\n"
      start = eol + 1
    end

    if start > 0
      @__linefeed_buffer = @__linefeed_buffer.byteslice(start, @__linefeed_buffer.bytesize - start) || +"".b
    end

    self
  end

  # Called at end-of-stream.
  def close(&per_line)
    per_line ||= @__linefeed_default
    raise Error, "already closed" if @__linefeed_closed
    raise ArgumentError, "no line handler" unless per_line
    @__linefeed_closed = true
    return self if !@__linefeed_buffer || @__linefeed_buffer.empty?

    per_line.call(@__linefeed_buffer.slice!(0, @__linefeed_buffer.bytesize)) # final unterminated line
    self
  end
end
