module Runbook
  module Statements
    class Notice < Runbook::Statement
      attr_reader :msg

      def initialize(msg)
        @msg = msg
      end
    end
  end
end
