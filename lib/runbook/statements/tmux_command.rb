module Runbook
  module Statements
    class TmuxCommand < Runbook::Statement
      attr_reader :cmd, :pane

      def initialize(cmd, pane)
        @cmd = cmd
        @pane = pane
      end
    end
  end
end
