# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/linefeed"

class LinefeedTest < Minitest::Test
  class StandardReceiver
    include Linefeed
    attr_reader :lines

    def initialize
      @lines = []
      linefeed { |line| @lines << line }
    end
  end

  class CustomReceiver
    include Linefeed
    attr_reader :lines

    def initialize
      @lines = []
    end

    def <<(chunk)
      super do |line|
        @lines << "line:#{line}"
      end
    end

    def close
      super do |line|
        @lines << "eof:#{line}"
      end
    end
  end

  def test_basic_yield
    receiver = StandardReceiver.new
    receiver << "olleh\ndlrow\n"
    receiver.close

    assert_equal ["olleh\n", "dlrow\n"], receiver.lines
  end

  def test_works_across_chunks
    receiver = StandardReceiver.new
    receiver << "it's"
    receiver << "\n"
    receiver << "been"
    receiver << "\n"
    receiver << "emotional"
    receiver << "\n"
    receiver.close

    assert_equal ["it's\n", "been\n", "emotional\n"], receiver.lines
  end

  def test_unterminated
    receiver = StandardReceiver.new
    receiver << "splash"
    receiver.close

    assert_equal ["splash"], receiver.lines
  end

  def test_unterminated_across_chunks
    receiver = StandardReceiver.new
    receiver << "abc"
    receiver << "def"
    receiver.close

    assert_equal ["abcdef"], receiver.lines
  end

  def test_embedded_lines
    receiver = StandardReceiver.new
    receiver << "turning\nand\nturn"
    receiver << "ing\nin\nthe\nwide"
    receiver << "ning\ngyre"
    receiver.close

    assert_equal ["turning\n", "and\n", "turning\n", "in\n", "the\n", "widening\n", "gyre"], receiver.lines
  end

  def test_custom_handlers
    receiver = CustomReceiver.new

    receiver << "quick"
    receiver << "\n"
    receiver << "fox"
    receiver.close
    assert_equal ["line:quick\n", "eof:fox"], receiver.lines
  end

  def test_empty_close_after_start_does_nothing
    receiver = StandardReceiver.new
    receiver.close

    assert_equal [], receiver.lines
  end

  def test_empty_close_without_start_does_nothing
    receiver = CustomReceiver.new
    receiver.close

    assert_equal [], receiver.lines
  end

  def test_you_forget_the_handlers
    obj = Object.new
    obj.extend(Linefeed)

    assert_raises(Linefeed::MissingHandler) { obj << "a\n" }
    assert_raises(Linefeed::MissingHandler) { obj.close }
  end

  def test_double_close
    receiver = StandardReceiver.new
    receiver.close

    assert_raises(Linefeed::ClosedError) { receiver << "a\n" }
    assert_raises(Linefeed::ClosedError) { receiver.close }
  end

  def test_start_after_close
    receiver = CustomReceiver.new
    receiver.close
    assert_raises(Linefeed::ClosedError) { receiver.linefeed { |line| ; } }
  end

  def test_false_start
    receiver = CustomReceiver.new
    receiver << ""
    assert_raises(Linefeed::StartError) { receiver.linefeed { |line| ; } }
  end

end
