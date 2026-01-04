# frozen_string_literal: true

module Demo
  # IO trap
  class Output
    def initialize(klass)=@prefix = klass.to_s
    def <<(obj)=puts "#{@prefix}: #{obj.inspect}"
    def close()=puts "#{@prefix} closed."
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
