# frozen_string_literal: true

# simple base for demos
module Demo
  class Consumer
    include Linefeed

    def initialize(output)
      @output = output

      linefeed do |line|
        output << process_line(line)
      end
    end
  end
end
