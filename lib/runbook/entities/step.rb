module Runbook
  module Entities
    class Step < Runbook::Entity
      def initialize(title = nil, tags: [], labels: {})
        super(title, tags:, labels:)
      end
    end
  end
end
