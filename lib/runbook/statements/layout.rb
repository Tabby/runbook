module Runbook
  module Statements
    class Layout < Runbook::Statement
      attr_reader :structure

      def initialize(structure)
        @structure = structure
      end
    end
  end
end
