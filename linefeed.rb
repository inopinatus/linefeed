# frozen_string_literal: true

# Linefeed
#
# Receive chunks of binary 8-bit ascii data and work on them as LF-terminated lines.
#
# Protocol via #<< and #finish:
#
# << will yield LF-terminated strings. Without a block, returns an array.
# finish will yield a single non-LF-terminated string, or nil if nothing available.

module Linefeed
  def linefeed(&default_proc)
    @__linefeed_default = default_proc
    @__linefeed_buffer = +"".b
    self
  end

  # Called by push-type source to write to us.
  def <<(chunk, &per_line)
    @__linefeed_buffer ||= +"".b
    per_line ||= @__linefeed_default
    raise ArgumentError, "no line handler" unless per_line

    @__linefeed_buffer << chunk

    while (eol = @__linefeed_buffer.index("\n"))
      per_line.call(@__linefeed_buffer.slice!(0..eol)) # includes the "\n"
    end

    self
  end

  # Called at end-of-stream.
  def finish(&per_line)
    per_line ||= @__linefeed_default
    raise ArgumentError, "no line handler" unless per_line
    return self if !@__linefeed_buffer || @__linefeed_buffer.empty?

    per_line.call(@__linefeed_buffer.slice!(0, @__linefeed_buffer.bytesize)) # final unterminated line
    self
  end
end


# sample usage

class Recipient1
  include Linefeed

  def initialize(id)
    @id = id
    setup
  end

  def setup
    linefeed do |line|
      puts "#{self.class.to_s}##{__method__} (#{@id}): got #{line.inspect}"
    end
  end
end

class Recipient2
  include Linefeed

  def initialize(id)
    @id = id
  end
  
  def <<(chunk)
    super(chunk) do |line|
      puts "#{self.class.to_s}##{__method__} (#{@id}): got #{line.inspect}"
    end
  end

  def finish
    super do |line|
      puts "#{self.class.to_s}##{__method__} (#{@id}): got #{line.inspect}"
    end
  end
end


recipients = [Recipient1.new(1), Recipient2.new(2), Recipient2.new(3)]
maxlen = 7
chunk = "".b

while chunk = $stdin.read(maxlen, chunk)
  recipients.each do |r|
    r << chunk
  end
end
recipients.each(&:finish)
