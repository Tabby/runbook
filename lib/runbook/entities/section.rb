module Runbook
  module Entities
    class Section < Runbook::Entity
      def initialize(title, tags: [], labels: {})
        super(title, tags:, labels:)
      end
    end
  end
end
