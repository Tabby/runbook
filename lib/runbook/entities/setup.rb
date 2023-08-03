module Runbook
  module Entities
    class Setup < Runbook::Entity
      def initialize(tags: [], labels: {})
        super('Setup', tags:, labels:)
      end
    end
  end
end
