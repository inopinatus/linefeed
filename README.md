# Linefeed

Linefeed turns a push-style byte stream, of any chunk size, into individually yielded lines.

* https://github.com/inopinatus/linefeed

## Why?

When you're downstream of the read on a binary-mode chunked stream and can't easily turn that into a nice efficient `IO#readlines`.

Also, it has nice properties if you chain them together.

## Install

```console
gem install linefeed
```

Or add it to your Gemfile:

```ruby
gem "linefeed"
```

## Protocol

Including `linefeed` supplies two methods, `#<<` and `#close`.  The idea is for external
producers to drive processing by calls to these methods.

- `#<<` accepts an arbitrary-size chunk of incoming data and yields each LF-terminated line
to a handler set by `linefeed { |line| ... }` as an 8-bit ASCII string.  Lines yielded
will include the trailing LF.

- `#close` marks end-of-incoming-data; if any data persists in the buffer, this yields a
final unterminated string to the same handler.

These method names are intentionally IO-ish so that you can mingle regular output files
& IO streams with `linefeed` objects.

## Usage

```ruby
require "linefeed"

class Collector
  include Linefeed

  def initialize
    @lines = []
    linefeed { |line| @lines << line }
  end
end

collector = Collector.new
collector << "hello\nwor"
collector << "ld\n"
collector.close

# @lines => ["hello\n", "world\n"]
```

Write custom `#<<` and `#close` handlers by passing blocks to `super` blocks:

```ruby
def <<(chunk)
  super(chunk) do |line|
    puts escape(line)
  end
end

def close
  super do |line|
    puts escape(line) + "\n"
  end
  puts " -- all done."
end
```

See `examples/` for more, like daisy-chaining, or updating a digest.

## Examples

Run `examples/demo.rb` and review the numbered examples it includes.

If testing with cooked interactive input at the console, note that `linefeed`'s examples necessarily read in binary mode, so ^D may not be instant EOF.

## License

MIT. Copyright (c) 2025 inopinatus.

## Contributing

At https://github.com/inopinatus/linefeed.
