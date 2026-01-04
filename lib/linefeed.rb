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
    handler ||= @lf_handler
    raise MissingHandler unless handler
    raise ClosedError if @lf_closed
    linefeed_start unless @lf_started
    buf = @lf_buffer

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
        @lf_buffer = line
      end
    end

    self
  end

  # Called at end-of-stream. Note that it is *not* an error to call
  # this without a prior call to #<< or #linefeed.
  #
  # Consumers overriding this method should use super { |line| ... }
  def close(&handler)
    handler ||= @lf_handler
    raise MissingHandler unless handler
    raise ClosedError if @lf_closed
    @lf_closed = true
    return self if !@lf_buffer || @lf_buffer.empty?
    handler.call(@lf_buffer.dup)
    @lf_buffer.clear
    self
  end

  private
  def linefeed_start(&handler)
    raise StartError, "already started" if @lf_started
    raise ClosedError if @lf_closed
    @lf_handler = handler
    @lf_buffer = +"".b
    @lf_closed = false
    @lf_started = true
    self
  end
end
