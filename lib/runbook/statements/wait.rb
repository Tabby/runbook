module Runbook
  module Statements
    class Wait < Runbook::Statement
      attr_reader :time

      def initialize(time)
        @time = time
      end
    end
  end
end
