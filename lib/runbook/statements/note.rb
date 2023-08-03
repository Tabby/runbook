module Runbook
  module Statements
    class Note < Runbook::Statement
      attr_reader :msg

      def initialize(msg)
        @msg = msg
      end
    end
  end
end
