module Runbook
  class Entity < Runbook::Node
    include Runbook::Hooks::Invoker
    const_set(:DSL, Runbook::DSL.class)

    def self.inherited(child_class)
      child_class.const_set(:DSL, Runbook::DSL.class)
    end

    attr_reader :title, :tags, :labels, :dsl

    def initialize(title, tags: [], labels: {}, parent: nil)
      @title = title
      @tags = tags
      @labels = labels
      @parent = parent
      @dsl = "#{self.class}::DSL".constantize.new(self)
    end

    def add(item)
      items << item
      item.parent = self
    end

    def items
      @items ||= []
    end

    ruby2_keywords def method_missing(method, *, &)
      if dsl.respond_to?(method)
        dsl.send(method, *, &)
      else
        super
      end
    end

    def respond_to?(name, include_private = false)
      !!(dsl.respond_to?(name) || super)
    end

    def render(view, output, metadata)
      invoke_with_hooks(view, self, output, metadata) do
        view.render(self, output, metadata)
        items.each do |item|
          new_metadata = _render_metadata(item, metadata)
          item.render(view, output, new_metadata)
        end
      end
    end

    def run(run, metadata)
      return if _should_reverse?(run, metadata)
      return if dynamic? && visited?

      invoke_with_hooks(run, self, metadata) do
        run.execute(self, metadata)
        next if _should_reverse?(run, metadata)

        loop do
          items.each_with_index do |item, index|
            new_metadata = _run_metadata(item, metadata, index)
            # Optimization
            break if _should_reverse?(run, new_metadata)

            item.run(run, new_metadata)
          end

          break unless _should_retraverse?(run, metadata)

          metadata[:reverse] = false
        end
      end
      visited!
    end

    def dynamic!
      items.each(&:dynamic!)
      @dynamic = true
    end

    def _render_metadata(item, metadata)
      index = items.select do |inner_item|
        inner_item.is_a?(Entity)
      end.index(item)

      metadata.merge(
        {
          depth: metadata[:depth] + 1,
          index:
        }
      )
    end

    def _run_metadata(item, metadata, index)
      pos_index = items.select do |inner_item|
        inner_item.is_a?(Entity) &&
          !inner_item.is_a?(Runbook::Entities::Setup)
      end.index(item)

      pos = if pos_index
              if metadata[:position].empty?
                (pos_index + 1).to_s
              else
                "#{metadata[:position]}.#{pos_index + 1}"
              end
            else
              metadata[:position]
            end

      metadata.merge(
        {
          depth: metadata[:depth] + 1,
          index:,
          position: pos
        }
      )
    end

    def _should_reverse?(run, metadata)
      return false unless metadata[:reverse]

      run.past_position?(metadata[:position], metadata[:start_at])
    end

    def _should_retraverse?(run, metadata)
      return false unless metadata[:reverse]

      run.start_at_is_substep?(self, metadata)
    end
  end
end
