module Runbook
  module Statements
    class RubyCommand < Runbook::Statement
      attr_reader :block

      def initialize(&block)
        @block = block
      end
    end
  end
end
