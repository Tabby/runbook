module Runbook
  module Extensions
    module Statements
      module DSL
        ruby2_keywords def method_missing(name, *, &)
          if (klass = Statements::DSL._statement_class(name))
            klass.new(*, &).tap do |statement|
              parent.add(statement)

              Runbook.runtime_methods << statement.into if statement.respond_to?(:into)
            end
          else
            super
          end
        end

        def respond_to?(name, include_private = false)
          !!(Statements::DSL._statement_class(name) || super)
        end

        def self._statement_class(name)
          "Runbook::Statements::#{name.to_s.camelize}".constantize
        rescue NameError # rubocop:disable Lint/SuppressedException
        end
      end
    end

    Runbook::Entities::Setup::DSL.prepend(Statements::DSL)
    Runbook::Entities::Step::DSL.prepend(Statements::DSL)
  end
end
