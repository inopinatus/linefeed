# frozen_string_literal: true

module Demo
  # IO trap
  class Output
    def initialize(klass)=@prefix = klass.to_s
    def <<(obj)=puts "#{@prefix}: #{obj.inspect}"
    def close()=puts "#{@prefix} closed."
  end

  # decouple from tty if demo run interactively
  def self.input_pipe(source)
    return source unless $stdin.tty?

    reader, writer = IO.pipe
    Thread.new do
      IO.copy_stream(source, writer)
    ensure
      writer.close unless writer.closed?
    end
    reader
  end

  # Example registry
  @example_classes = []
  class << self
    def const_added(const_name)
      super
      return unless const_get(const_name, false) in Class => klass

      register(klass)
    end

    def register(klass)
      @example_classes << klass
    end

    def setup_examples
      @example_classes.map { |k| k.new(Output.new(k)) }
    end
  end
end
