# Linefeed

Linefeed turns a chunked byte stream into individually yielded lines.

* https://github.com/inopinatus/linefeed
* https://inopinatus.github.io/linefeed/

## Why?

When you're downstream of the read on a binary-mode chunked stream and want a push-style
take on `#each_line` that doesn't burn too much memory.

## Install

```console
gem install linefeed
```

Or add it to your Gemfile:

```ruby
gem "linefeed"
```

## Protocol

Including `Linefeed` supplies two methods, `#<<` and `#close`.  The idea is for external
producers to drive processing by calls to these methods.

- `#<<` accepts an arbitrary-size chunk of incoming data and yields each LF-terminated line
to a handler set by `linefeed { |line| ... }`.  Lines yielded will be 8-bit ASCII strings
and include the trailing LF.

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

See Examples for more, like daisy-chaining, or updating a digest.

## Note

If testing with cooked interactive input at the console, note that linefeed's demo naturally reads in binary mode, so `^D` may not be instant EOF.

## License

MIT license. Copyright (c) 2026 inopinatus

## Contributing

Visit https://github.com/inopinatus/linefeed to open a PR.
