module Runbook
  module Extensions
    module Setup
      module DSL
        def setup(*tags, labels: {}, &block)
          Runbook::Entities::Setup.new(
            tags:,
            labels:
          ).tap do |setup|
            parent.add(setup)
            setup.dsl.instance_eval(&block) if block
          end
        end
      end
    end

    Runbook::Entities::Book::DSL.prepend(Setup::DSL)
  end
end
