module Runbook
  module Extensions
    module Tmux
      module LayoutDSL
        def layout(layout)
          Runbook::Statements::Layout.new(layout).tap do |new_layout|
            parent.add(new_layout)
          end
        end
      end
    end

    Runbook::Entities::Book::DSL.prepend(Tmux::LayoutDSL)
  end
end
