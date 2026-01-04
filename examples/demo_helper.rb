# frozen_string_literal: true

module Demo
  # IO trap
  class Output
    def initialize(klass)=@prefix = klass.to_s
    def <<(o)=puts "#{@prefix}: #{o.inspect}"
    def close()=puts "#{@prefix} closed."
  end

  # Example registry
  @example_classes = []
  class << self
    def const_added(const_name)
      super
      if const_get(const_name, false) in Class => klass
        register(klass)
      end
    end

    def register(klass)
      @example_classes << klass
    end

    def setup_examples
      @example_classes.map { |k| k.new(Output.new(k)) }
    end
  end
end

