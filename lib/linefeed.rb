# frozen_string_literal: true

require "linefeed/version"
require "linefeed/errors"

# Include Linefeed to enable handling of chunked binary streams as yielded
# lines.
#
# See README for more.

module Linefeed
  # Set up linefeed processing and install a default handler.
  #
  # call-seq:
  #   linefeed { |line| ... } -> self
  #
  # The handler receives each LF-terminated line as a binary +String+ and will
  # be invoked on #<< and #close unless a per-call block is provided.  A final
  # unterminated line may be yielded by #close.
  #
  # Raises MissingHandler if no block is given.  
  # Raises StartError if linefeed was already started.  
  # Raises ClosedError if linefeed was already closed.
  def linefeed(&handler)
    raise MissingHandler unless block_given?
    linefeed_start(&handler)
  end

  # Push a binary chunk to the receiver.
  #
  # call-seq:
  #   self << chunk -> self
  #   self << chunk { |line| ... } -> self
  #
  # The receiver yields complete LF-terminated lines to the handler.
  # Any # trailing partial line is buffered until the next chunk or #close.
  # Lines will be 8-bit ASCII +String+ values and always include the trailing +\n+.
  #
  # If you override this method, call +super+ with the chunk and pass a block
  # to receive each line:
  #
  #   def <<(chunk)
  #     super(chunk) { |line| puts escape(line) }
  #   end
  #
  # Raises MissingHandler if no handler is given and no default handler was installed.  
  # Raises ClosedError if called after #close.
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

  # Close the stream and flush any buffered data.
  #
  # call-seq:
  #   close -> self
  #   close { |line| ... } -> self
  #
  # If the buffer contains an unterminated line, it is yielded once to the
  # handler as a binary +String+ without a trailing +\n+.

  # It is valid to call #close without any prior calls to #<< or #linefeed.
  #
  # If you override this method, call +super+ and pass a block to receive the
  # final partial line:
  #
  #   def close
  #     super { |line| puts escape(line) }
  #     puts "-- all done."
  #   end
  #
  # Raises MissingHandler if no handler is given and no default handler was installed.  
  # Raises ClosedError if called more than once.
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
