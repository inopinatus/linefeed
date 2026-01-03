# frozen_string_literal: true

# Linefeed
#
# Receive chunks of binary 8-bit ascii data and work on them as LF-terminated lines.
#
# Producer must call with #<< and #close:
#
# <<     will yield LF-terminated strings, one line at a time
# close  will yield a single non-LF-terminated string, if available

module Linefeed
  class Error < StandardError; end

  def linefeed(&default_proc)
    @__linefeed_default = default_proc
    __linefeed_reset
    self
  end

  def __linefeed_reset
    @__linefeed_buffer = +"".b
    @__linefeed_closed = false
    self
  end

  # Called by push-type source to write to us.
  def <<(chunk, &per_line)
    per_line ||= @__linefeed_default
    raise Error, "already closed" if @__linefeed_closed
    raise ArgumentError, "no line handler" unless per_line

    @__linefeed_buffer ||= +"".b
    @__linefeed_buffer << chunk

    while (eol = @__linefeed_buffer.index("\n"))
      per_line.call(@__linefeed_buffer.slice!(0..eol)) # includes the "\n"
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




# demo usages

# Simplest possible example
class Logger
  include Linefeed

  def initialize(id, output)
    @id = id
    line_no = 0
    linefeed do |line|
      output << "%.3d => %s" % [line_no += 1, line]
    end
  end
end


# simple base for demos
class Consumer
  include Linefeed

  def initialize(id, output)
    @id = id
    @output = output

    linefeed do |line|
      output << process_line(line)
    end
  end
end


# has init/per-line/close behaviour
class Canonicalize < Consumer
  def initialize(*)
    super
    @output << "---------- START\r\n"
    @output << "Canonicalized: yes\r\n"
    @output << "\r\n"
  end

  def process_line(line)
    canonicalize(line)
  end

  def canonicalize(line)
    line.chomp.sub(/[ \t]+$/, '') + "\r\n"     
  end

  def close
    super
    @output << "---------- END\r\n"
    @output.close
  end
end

# has no default proc
class Escaped < Consumer
  def escape(line)
    line.sub(/^(-|From )/, '- \\1')
  end

  def <<(chunk)
    super(chunk) do |line|
      @output << escape(line)
    end
  end

  def close
    super do |line|
      @output << escape(line) + "\n"
    end
  end
end

require 'digest'

class LineDigest
  include Linefeed

  def initialize(id, output)
    @id = id
    @output = output
    @line_digest = Digest("SHA256").new

    linefeed do |line|
      @line_digest.update(line)
    end
  end

  def close
    super
    @output << @line_digest.hexdigest
  end
end

# Not actually using Linefeed, just speaking the same protocol, and consuming
# entire chunks.  Should give the same digest as LineDigest above, at the end.
class ChunkDigest
  def initialize(id, output)
    @id = id
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



# Easy chaining.
require 'delegate'
class CanonicalizedDigest < DelegateClass(Consumer)
  def initialize(id, output)
    @id = id
    super(Canonicalize.new("for #{id}", LineDigest.new("for #{id}", output)))
  end
end


# Fails to setup the feed and suffers for it
class Null
  include Linefeed

  def initialize(id, output)
    @id = id
    @output = output
    @count = 0
  end

  def <<(*)
    super
  rescue
    @count += 1
  end

  def close
    super
  rescue
    @output << "rescued #{@count+=1} time(s)"
  end
end


# Todo:
# Maybe show how to use with Ractors, Fibers, Enumerators, Thread::Queue.


# Drive the demos

class Output
  def initialize(klass, idx)
    @prefix = "#{klass.to_s}#(#{idx})"
  end

  def <<(o)
    puts "#{@prefix}: #{o.inspect}"
  end

  def close
    puts "#{@prefix} closed."
  end
end


recipients = [Logger, Canonicalize, Escaped, LineDigest, ChunkDigest, Null, CanonicalizedDigest].map.with_index { |k, i| k.new(i, Output.new(k, i)) }

maxlen = 8192
chunk = "".b

while chunk = $stdin.read(maxlen, chunk)
  recipients.each do |r|
    r << chunk
  end
end
recipients.each(&:close)
